# Feature Spec: 招待機能 招待コード入力画面（INV-3）

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-15
Requirement: `docs/Requirements/REQ-invitation_code_input.md`

---

# 1. Feature Overview

## Feature Name

InviteCodeInput

## Purpose

招待コード（XXX-9999形式）を手入力してイベントに参加できる Flutter 画面を実装する。
コード入力 → バリデーション → member選択 → 参加確定 の2ステップフローを BLoC で制御する。

## Scope

**含むもの**
- `InviteCodeInputPage`（招待コード入力 → member選択 → 参加確定）
- `InviteCodeInputBloc` / `InviteCodeInputEvent` / `InviteCodeInputState`
- `InviteCodeInputProjection`
- `InviteCodeInputAdapter`
- `InvitationRepository`（HTTP呼び出し）
- イベント一覧画面への導線追加

**含まないもの**
- 招待リンク生成・共有（INV-4 の責務）
- Web中間ページ（INV-2 の責務）
- deep link からのアプリ起動（INV-4 の責務）

---

# 2. 前提条件

- INFRA-1（Firebase Anonymous Auth）完了
- INV-1（バックエンドAPI）完了
- INV-1 API追加: `GET /api/invitations/code/[code]` の追加が必要（§4.3 参照）

---

# 3. 画面フロー

```
イベント一覧
  └─ 「招待コードで参加」ボタン
        ↓ router.push('/invite-code')
  ┌─────────────────────────────┐
  │ Step 1: コード入力           │
  │  [ABC-1234    ]             │
  │  [次へ]                     │
  └─────────────────────────────┘
        ↓ コード検証（GET /api/invitations/code/[code]）
  ┌─────────────────────────────┐
  │ Step 2: メンバー選択        │
  │  イベント: [eventName]      │
  │  あなたはどのメンバーですか？ │
  │  ○ 山田 太郎               │
  │  ○ 田中 花子               │
  │  [参加する]                 │
  └─────────────────────────────┘
        ↓ 参加確定（POST /api/invitations/code）
  ┌─────────────────────────────┐
  │ 「[eventName]に参加しました！」│
  └─────────────────────────────┘
        ↓ router.go('/events/[eventId]')
```

---

# 4. API依存

## 4.1 既存エンドポイント（INV-1）

### POST /api/invitations/code（参加確定）

```typescript
// Request
{ code: string; uid: string; memberId: string; }
// Response（成功）
{ eventId: string; role: 'viewer' | 'editor'; }
// Response（エラー）
{ errorType: 'expired' | 'used_up' | 'not_found' | 'already_joined' | 'member_already_linked' | 'invalid_request'; message: string; }
```

## 4.2 既存エンドポイント（INV-1）

### GET /api/invitations/[token]/members（member一覧取得）

member一覧はtokenベース。コード入力フローでは次の新規APIを使う。

## 4.3 新規エンドポイント（INV-1 API追加）

### GET /api/invitations/code/[code]

コード入力フローの Step 1 → Step 2 遷移に必要。INV-1 実装側で追加対応すること。

**バリデーション:**
- `code` : URLパスパラメータ・`^[A-Z]{3}-[0-9]{4}$` 正規表現に一致すること
- 招待の有効性チェック（expired / used_up / not_found）

**Firestore操作（INV-1 `GET /api/invitations/[token]` と同一ロジック）:**
1. `invitations` コレクションで `code == [code]` のドキュメントを取得
2. 有効性チェック後、orgIdからメンバー一覧（linkedUid == null）を取得

**レスポンス:**

```typescript
// 成功
type CodeInvitationInfoResponse = {
  token: string;       // 以降のPOSTに使用する（tokenでも可）
  eventName: string;
  inviterName: string;
  role: 'viewer' | 'editor';
  members: Array<{ memberId: string; memberName: string }>;
};

// エラー（200で返す）
type InvitationErrorResponse = {
  errorType: 'expired' | 'used_up' | 'not_found';
};
```

---

# 5. BLoC 設計

## 5.1 State

```dart
sealed class InviteCodeInputState extends Equatable {
  const InviteCodeInputState();
}

// 初期状態（コード入力中）
class InviteCodeInputInitial extends InviteCodeInputState {
  final String code;                // 入力中のコード
  final String? formatError;       // フォーマットエラー（null = エラーなし）
  const InviteCodeInputInitial({ this.code = '', this.formatError });
}

// コード検証中
class InviteCodeInputValidating extends InviteCodeInputState {}

// コード検証OK → member選択ステップ
class InviteCodeInputMemberSelection extends InviteCodeInputState {
  final String code;
  final String eventName;
  final List<InviteCodeMemberItem> members;
  final String? selectedMemberId;
  const InviteCodeInputMemberSelection({
    required this.code,
    required this.eventName,
    required this.members,
    this.selectedMemberId,
  });
}

// 参加処理中
class InviteCodeInputJoining extends InviteCodeInputState {}

// 参加成功
class InviteCodeInputJoined extends InviteCodeInputState {
  final String eventId;
  final String eventName;
  const InviteCodeInputJoined({ required this.eventId, required this.eventName });
}

// エラー（API エラー）
class InviteCodeInputError extends InviteCodeInputState {
  final InviteCodeErrorType errorType;
  const InviteCodeInputError({ required this.errorType });
}
```

## 5.2 Event

```dart
sealed class InviteCodeInputEvent extends Equatable {
  const InviteCodeInputEvent();
}

// コード文字列が変化
class InviteCodeChanged extends InviteCodeInputEvent {
  final String code;
  const InviteCodeChanged(this.code);
}

// 「次へ」ボタン → コード検証開始
class InviteCodeSubmitted extends InviteCodeInputEvent {}

// メンバー選択
class InviteCodeMemberSelected extends InviteCodeInputEvent {
  final String memberId;
  const InviteCodeMemberSelected(this.memberId);
}

// 「参加する」ボタン → 参加確定
class InviteCodeJoinConfirmed extends InviteCodeInputEvent {}

// コード入力ステップに戻る
class InviteCodeBackToInput extends InviteCodeInputEvent {}
```

## 5.3 エラー種別

```dart
enum InviteCodeErrorType {
  expired,
  usedUp,
  notFound,
  alreadyJoined,
  memberAlreadyLinked,
  networkError,
}
```

## 5.4 BLoC 処理フロー

```
InviteCodeChanged
  → 自動大文字変換（code.toUpperCase()）
  → formatError をクリア
  → InviteCodeInputInitial(code: 変換後文字列) をemit

InviteCodeSubmitted
  → フォーマット検証: ^[A-Z]{3}-[0-9]{4}$
    NG → InviteCodeInputInitial(formatError: 'ABC-1234の形式で入力してください') をemit
    OK → InviteCodeInputValidating をemit
         → GET /api/invitations/code/[code] 呼び出し
           成功 → InviteCodeInputMemberSelection をemit
           エラー → InviteCodeInputError をemit

InviteCodeMemberSelected
  → InviteCodeInputMemberSelection(selectedMemberId: memberId) をemit

InviteCodeJoinConfirmed（selectedMemberId != null が前提）
  → InviteCodeInputJoining をemit
  → POST /api/invitations/code 呼び出し
    成功 → InviteCodeInputJoined をemit
    エラー → InviteCodeInputError をemit

InviteCodeBackToInput
  → InviteCodeInputInitial() をemit
```

---

# 6. ファイル構成

```
flutter/lib/features/invite_code_input/
  bloc/
    invite_code_input_bloc.dart
    invite_code_input_event.dart
    invite_code_input_state.dart
  domain/
    invite_code_member_item.dart     ← { memberId, memberName }
    invite_code_error_type.dart
  adapter/
    invite_code_input_adapter.dart   ← API レスポンス → Domain 変換
  repository/
    invitation_repository.dart       ← HTTP呼び出し
  view/
    invite_code_input_page.dart      ← ページ本体
    invite_code_input_view.dart      ← BlocBuilder/BlocListener
    widgets/
      code_input_step.dart           ← Step1 UI
      member_selection_step.dart     ← Step2 UI
      error_view.dart                ← エラー表示
```

---

# 7. 画面仕様

## 7.1 AppBar

- タイトル: 「招待コードで参加」
- 戻るボタン: 標準の `<` アイコン（イベント一覧に戻る）

## 7.2 Step 1: コード入力

```
招待コードを入力してください

┌─────────────────────────────┐
│  ABC-1234                   │  ← TextField
└─────────────────────────────┘
  ABC-1234の形式で入力してください  ← formatError（エラー時のみ）

[次へ]  ← ElevatedButton（コード空欄時はdisabled）
```

- TextField: `TextInputType.text`・`textCapitalization: TextCapitalization.characters`
- コード変更時に `InviteCodeChanged` を dispatch
- 「次へ」タップ時に `InviteCodeSubmitted` を dispatch
- `Key('invite_code_text_field')`
- 「次へ」ボタン: `Key('invite_code_next_button')`

## 7.3 Step 2: メンバー選択

```
[eventName]

あなたはどのメンバーですか？

○ 山田 太郎  ← Radio（Key('member_radio_[memberId]')）
○ 田中 花子

[参加する]  ← ElevatedButton（未選択時はdisabled）
[戻る]      ← TextButton
```

- メンバー選択時に `InviteCodeMemberSelected` を dispatch
- 「参加する」タップ時に `InviteCodeJoinConfirmed` を dispatch
- 「戻る」タップ時に `InviteCodeBackToInput` を dispatch
- 「参加する」ボタン: `Key('invite_code_join_button')`

## 7.4 ローディング

- `InviteCodeInputValidating` / `InviteCodeInputJoining` 中は `CircularProgressIndicator` を表示
- ボタンをdisabledにする

## 7.5 成功アラート

`InviteCodeInputJoined` を BlocListener で受け取り、`showCupertinoDialog` で表示する。

```
「[eventName]に参加しました！」
[OK]
```

OK タップ後: `router.go('/events/${eventId}')`

## 7.6 エラー表示

| errorType | 表示メッセージ |
|---|---|
| `expired` | 「この招待コードの有効期限が切れています」 |
| `usedUp` | 「この招待コードは使用済みです」 |
| `notFound` | 「招待コードが見つかりません」 |
| `alreadyJoined` | 「すでにこのイベントに参加しています」 |
| `memberAlreadyLinked` | 「このメンバーはすでに別のアカウントに紐づいています」 |
| `networkError` | 「通信エラーが発生しました。もう一度お試しください」 |

エラー表示エリアは Step 1 / Step 2 ともにフォームの下部に常設する。
`Key('invite_code_error_message')`

---

# 8. ルーティング

## 8.1 新規ルート

| パス | 画面 |
|---|---|
| `/invite-code` | `InviteCodeInputPage` |

`router.dart` に追加する。

## 8.2 イベント一覧画面への導線

既存の `EventListPage` に「招待コードで参加」ボタンを追加する。
- 追加位置: AppBar の actions（または FAB メニュー内）
- 設計憲章に従い既存UIの構成を確認してから実装位置を決定すること
- `Key('event_list_invite_code_button')`

---

# 9. テストシナリオ

## 9.1 テストファイル

`flutter/integration_test/invite_code_input_test.dart`

## 9.2 テストシナリオ一覧

| ID | シナリオ | ステップ | 優先度 |
|---|---|---|---|
| TC-INV3-001 | 有効なコード入力 → メンバー選択 → 参加成功 → イベント詳細画面へ遷移 | Step1入力→次へ→Step2メンバー選択→参加する→成功ダイアログOK→遷移確認 | 高 |
| TC-INV3-002 | 不正フォーマット（小文字）入力 → フォーマットエラーが表示され、APIは呼ばれない | Step1入力（"abc-1234"）→次へ→フォーマットエラー確認 | 高 |
| TC-INV3-003 | 不正フォーマット（数字のみ）入力 → フォーマットエラー表示 | Step1入力（"12345678"）→次へ→エラー確認 | 中 |
| TC-INV3-004 | コードが空の状態では「次へ」ボタンがdisabled | 入力なし→ボタンdisabled確認 | 中 |
| TC-INV3-005 | expired コード → エラーメッセージ「有効期限が切れています」表示 | Step1入力→次へ→エラーメッセージ確認 | 高 |
| TC-INV3-006 | not_found コード → エラーメッセージ「見つかりません」表示 | Step1入力→次へ→エラーメッセージ確認 | 高 |
| TC-INV3-007 | already_joined → エラーメッセージ「すでに参加しています」表示 | Step1入力→次へ→Step2→参加→エラーメッセージ確認 | 高 |
| TC-INV3-008 | Step2でメンバー未選択時は「参加する」ボタンがdisabled | Step2遷移後→選択なし→ボタンdisabled確認 | 中 |
| TC-INV3-009 | Step2で「戻る」タップ → Step1に戻りコード入力が保持される | Step2→戻る→Step1→コード確認 | 中 |
| TC-INV3-010 | イベント一覧画面に「招待コードで参加」ボタンが表示され、タップでInviteCodeInputPageへ遷移 | 一覧画面→ボタンタップ→画面遷移確認 | 高 |

---

# 10. 依存関係

- **INFRA-1:** Firebase Anonymous Auth（uid取得）
- **INV-1:** POST /api/invitations/code（参加確定）
- **INV-1 API追加:** GET /api/invitations/code/[code]（コード検証・member一覧）
- **INV-2:** 独立（並行実施可能）
- **INV-4:** 独立（並行実施可能）
