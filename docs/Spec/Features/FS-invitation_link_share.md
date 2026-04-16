# Feature Spec: 招待リンク生成・共有（INV-4）

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-16
Requirement: `docs/Requirements/REQ-invitation_link_share.md`

---

# 1. Feature Overview

## Feature Name

InviteLinkShare（招待リンク生成・共有）

## Purpose

イベントオーナーが招待設定（権限・有効期限・使用回数）を選択して招待リンクを生成し、LINEやコピーで共有できる機能を提供する。
F-7（FS-invitation_ui_placement）で追加された「メンバーを招待」ボタンからBottomSheetを表示し、設定 -> 生成 -> 共有の一連のフローをBLoCで制御する。

## Scope

含むもの
- 招待設定BottomSheet（権限・有効期限・使用回数の選択UI）
- 招待リンク生成（POST /api/invitations 呼び出し）
- 生成結果表示（招待URL・招待コード・コピーボタン・シェアボタン）
- `InviteLinkShareBloc` / Event / State 設計
- `InvitationRepository` への `createInvitation` メソッド追加
- スタブ実装（INV-1バックエンドAPI未実装対応）
- EventDetailBloc / Page へのDelegate連携（F-7で追加済みのEvent・Delegateの実処理追加）

含まないもの
- バックエンドAPI実装（INV-1の責務）
- 中間Webページ（INV-2の責務）
- 招待コード入力画面（INV-3で実装済み）
- deep linkからのアプリ起動ハンドリング（将来対応）

---

# 2. 前提条件

- INFRA-1（Firebase基盤整備）の完了が前提
- INV-1（バックエンドAPI）は未実装。API呼び出し部分はRepository層で抽象化し、スタブ実装で対応する
- F-7（FS-invitation_ui_placement）の完了が前提。`EventDetailInviteLinkButtonPressed` イベントと `EventDetailOpenInviteLinkDelegate` が既に定義されていること
- 既存の `InvitationRepository`（INV-3で定義済み）を拡張する

---

# 3. 画面フロー

```
イベント詳細画面（概要タブ）
  └─ 「メンバーを招待」ボタン（owner のみ表示・F-7 実装済み）
        ↓ EventDetailInviteLinkButtonPressed
        ↓ EventDetailPage._handleDelegate → showModalBottomSheet
  ┌─────────────────────────────────────────┐
  │ Step 1: 招待設定                         │
  │                                         │
  │  権限                                    │
  │  ○ 編集可能（デフォルト）                  │
  │  ○ 閲覧のみ                              │
  │                                         │
  │  有効期限                                 │
  │  [ 24時間 ] [ 72時間 ] [ 7日間 ]          │
  │                                         │
  │  使用回数                                 │
  │  [ 1回 ] [ 5回 ] [ 無制限 ]               │
  │                                         │
  │  [招待リンクを作成]                        │
  └─────────────────────────────────────────┘
        ↓ POST /api/invitations（スタブ）
  ┌─────────────────────────────────────────┐
  │ Step 2: 生成結果                         │
  │                                         │
  │  招待リンク                               │
  │  https://michimark.../invite/abc123xy    │
  │  [リンクをコピー]                         │
  │                                         │
  │  招待コード                               │
  │  ABC-1234                                │
  │  [コードをコピー]                         │
  │                                         │
  │  [共有する]  ← iOS標準シェアシート         │
  │                                         │
  │  [閉じる]                                │
  └─────────────────────────────────────────┘
```

---

# 4. Feature Responsibility

- `InviteLinkShareBloc` が Draft（設定値）を所有する
- Draft 更新（権限・有効期限・使用回数の選択反映）
- Repository 経由で招待リンクを生成する
- 生成結果を State に保持して Widget に公開する

EventDetailBloc は Delegate で BottomSheet 表示を指示するのみ。招待生成ロジックは `InviteLinkShareBloc` が担当する。

---

# 5. State Structure

## InviteLinkShareState

```
sealed class InviteLinkShareState extends Equatable
```

| State | フィールド | 説明 |
|---|---|---|
| `InviteLinkShareSetting` | `draft: InviteLinkShareDraft` | Step 1: 設定選択中 |
| `InviteLinkShareCreating` | `draft: InviteLinkShareDraft` | API呼び出し中（ローディング） |
| `InviteLinkShareCreated` | `result: InviteLinkShareResult` | Step 2: 生成完了・結果表示 |
| `InviteLinkShareError` | `errorMessage: String`, `draft: InviteLinkShareDraft` | 生成失敗 |

---

# 6. Draft Model

## InviteLinkShareDraft

招待設定の編集状態を保持する。

| フィールド | 型 | デフォルト | 説明 |
|---|---|---|---|
| `role` | `InviteLinkRole` | `editor` | 招待権限 |
| `expiresHours` | `int` | `24` | 有効期限（時間） |
| `maxUses` | `int?` | `1` | 最大使用回数。null = 無制限 |

## InviteLinkRole（enum）

| 値 | 表示文字列 | APIに送る値 |
|---|---|---|
| `editor` | 「編集可能」 | `'editor'` |
| `viewer` | 「閲覧のみ」 | `'viewer'` |

**注意:** Domain層の `InvitationRole`（owner / editor / viewer）とは別の型。Draft専用のUI選択肢として定義する。`owner` はユーザーが選択する権限ではないため含まない。

## 有効期限・使用回数の選択肢

| 有効期限選択肢 | 値（expiresHours） |
|---|---|
| 「24時間」 | `24` |
| 「72時間」 | `72` |
| 「7日間」 | `168` |

| 使用回数選択肢 | 値（maxUses） |
|---|---|
| 「1回」 | `1` |
| 「5回」 | `5` |
| 「無制限」 | `null` |

---

# 7. Domain Model

## InviteLinkShareResult

生成結果を表すDomainモデル。

| フィールド | 型 | 説明 |
|---|---|---|
| `token` | `String` | 招待トークン（URL用8文字英数字） |
| `code` | `String` | 招待コード（XXX-9999形式） |
| `inviteUrl` | `String` | 招待URL全体（`https://[domain]/invite/[token]`） |
| `expiresAt` | `DateTime` | 有効期限日時 |

---

# 8. Projection Model

本Featureでは独立したProjectionクラスは作成しない。
`InviteLinkShareCreated` State が `InviteLinkShareResult` を直接保持し、Widget が参照する。
表示フォーマット（有効期限の日時表示など）が必要になった場合は Adapter 経由で Projection を追加する。

---

# 9. Adapter

## InviteLinkShareAdapter

| メソッド | 入力 | 出力 | 説明 |
|---|---|---|---|
| `toCreateRequest` | `InviteLinkShareDraft`, `String eventId`, `String uid` | `CreateInvitationRequest` | Draft + コンテキスト情報 -> API リクエスト型への変換 |
| `toResult` | `CreateInvitationResponse` | `InviteLinkShareResult` | APIレスポンス -> Domain結果型への変換 |

## CreateInvitationRequest

Repository に渡すリクエスト型。

| フィールド | 型 | 説明 |
|---|---|---|
| `orgId` | `String` | organizations の orgId（= ownerのuid） |
| `eventId` | `String` | イベントID |
| `invitedBy` | `String` | 招待者の Firebase UID |
| `role` | `String` | `'editor'` or `'viewer'` |
| `expiresHours` | `int` | 有効期限（時間） |
| `maxUses` | `int?` | 最大使用回数。null = 無制限 |

## CreateInvitationResponse

Repository から返るレスポンス型。

| フィールド | 型 | 説明 |
|---|---|---|
| `token` | `String` | 招待トークン |
| `code` | `String` | 招待コード |
| `expiresAt` | `DateTime` | 有効期限日時 |
| `inviteUrl` | `String` | 招待URL |

---

# 10. Events

## InviteLinkShareEvent

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `InviteLinkShareStarted` | BottomSheet表示時 | eventId を受け取って初期化する |
| `InviteLinkRoleChanged` | 権限ラジオボタン変更時 | `InviteLinkRole` を受け取る |
| `InviteLinkExpiresHoursChanged` | 有効期限ボタン変更時 | `int` expiresHours を受け取る |
| `InviteLinkMaxUsesChanged` | 使用回数ボタン変更時 | `int?` maxUses を受け取る |
| `InviteLinkCreatePressed` | 「招待リンクを作成」ボタンタップ時 | 招待リンク生成API呼び出しを開始する |
| `InviteLinkUrlCopied` | 「リンクをコピー」ボタンタップ時 | クリップボードにURLをコピーする（UIフィードバックのみ） |
| `InviteLinkCodeCopied` | 「コードをコピー」ボタンタップ時 | クリップボードにコードをコピーする（UIフィードバックのみ） |

---

# 11. Delegate

本FeatureはBottomSheet内で完結するため、Delegateは使用しない。
BottomSheet表示の起点はEventDetailBlocの既存Delegate（F-7定義済み）で処理する。

## EventDetailBloc 側の既存Delegate処理（F-7で追加済み、INV-4で実処理を実装）

F-7で `EventDetailInviteLinkButtonPressed` と対応する Delegate が定義されているが、`EventDetailPage._handleDelegate` の switch に INV-4 用の case がまだない。
INV-4 実装時に以下を追加する:

- `EventDetailOpenInviteLinkDelegate` が未定義の場合は新規追加する
- `_handleDelegate` の switch case で `showModalBottomSheet` を呼び出す

**注意:** F-7 の Spec では `EventDetailOpenInviteLinkDelegate` が定義されているが、現在の実装コードには含まれていない。INV-4 実装時に Delegate クラスの追加と switch case の追加が必要。

---

# 12. Bloc Responsibility

## InviteLinkShareBloc

コンストラクタ引数:
- `InvitationRepository invitationRepository`（DI経由）
- `AuthRepository authRepository`（DI経由、currentUid取得用）
- `String eventId`（BottomSheet表示時に渡す）

### InviteLinkShareStarted
1. `InviteLinkShareSetting(draft: InviteLinkShareDraft())` をemitする（デフォルト値で初期化）

### InviteLinkRoleChanged
1. Draft の `role` を更新する
2. `InviteLinkShareSetting(draft: 更新後Draft)` をemitする

### InviteLinkExpiresHoursChanged
1. Draft の `expiresHours` を更新する
2. `InviteLinkShareSetting(draft: 更新後Draft)` をemitする

### InviteLinkMaxUsesChanged
1. Draft の `maxUses` を更新する
2. `InviteLinkShareSetting(draft: 更新後Draft)` をemitする

### InviteLinkCreatePressed
1. `InviteLinkShareCreating(draft: currentDraft)` をemitする
2. `AuthRepository.currentUid` を取得する
3. `InviteLinkShareAdapter.toCreateRequest(draft, eventId, uid)` でリクエストを生成する
4. `InvitationRepository.createInvitation(request)` を呼び出す
5. 成功時: `InviteLinkShareAdapter.toResult(response)` で結果を変換し `InviteLinkShareCreated(result)` をemitする
6. 失敗時: `InviteLinkShareError(errorMessage, draft)` をemitする

### InviteLinkUrlCopied / InviteLinkCodeCopied
- Bloc ではクリップボード操作を行わない（Widget 側で `Clipboard.setData` を呼ぶ）
- Bloc は SnackBar 表示のためのフラグ管理のみ行う（必要に応じて State にフラグを追加）

禁止事項:
- Bloc 内で `Clipboard.setData` を呼び出すこと（プラットフォーム依存のUI操作）
- Bloc 内で `Navigator` / `context.go()` を呼び出すこと
- Bloc 内で `Share.share()` を呼び出すこと

---

# 13. Repository 拡張

## InvitationRepository（既存 abstract class への追加）

格納場所: `flutter/lib/features/invite_code_input/repository/invitation_repository.dart`

既存メソッド（INV-3で定義済み）:
- `getInvitationByCode(String code)` -> `Future<CodeInvitationInfo>`
- `joinByCode({code, uid, memberId})` -> `Future<JoinResult>`

追加メソッド:

| メソッド名 | 戻り値型 | 説明 |
|---|---|---|
| `createInvitation(CreateInvitationRequest request)` | `Future<CreateInvitationResponse>` | POST /api/invitations 呼び出し |

## StubInvitationRepository への追加

`createInvitation` のスタブ実装を追加する。固定のダミーデータを返す。

スタブレスポンス:
- `token`: `'stub-token-inv4'`
- `code`: `'STB-0001'`
- `expiresAt`: 現在時刻 + expiresHours
- `inviteUrl`: `'https://michimark.example.com/invite/stub-token-inv4'`

---

# 14. View

## 14.1 BottomSheet 起動

`EventDetailPage._handleDelegate` に以下の case を追加する:

`EventDetailOpenInviteLinkDelegate` を受け取ったとき:
- `showModalBottomSheet` で `InviteLinkShareSheet` を表示する
- `BlocProvider` で `InviteLinkShareBloc` を提供する
- `eventId` を Bloc のコンストラクタに渡す

## 14.2 InviteLinkShareSheet（BottomSheet本体）

`BlocBuilder<InviteLinkShareBloc, InviteLinkShareState>` で State に応じた表示を切り替える。

### Step 1: 設定画面（`InviteLinkShareSetting` State）

```
BottomSheet
  └─ SingleChildScrollView
       └─ Column
            ├─ BottomSheet ハンドルバー
            ├─ Text('メンバーを招待')  ← タイトル
            ├─ Divider
            ├─ _RoleSelector          ← 権限選択（Radio）
            ├─ _ExpiresSelector       ← 有効期限選択（SegmentedButton or ChoiceChip）
            ├─ _MaxUsesSelector       ← 使用回数選択（SegmentedButton or ChoiceChip）
            └─ ElevatedButton('招待リンクを作成')
```

### Step 2: 結果表示（`InviteLinkShareCreated` State）

```
BottomSheet
  └─ SingleChildScrollView
       └─ Column
            ├─ BottomSheet ハンドルバー
            ├─ Text('招待リンクを作成しました')  ← タイトル
            ├─ Divider
            ├─ _UrlSection             ← 招待URL表示 + コピーボタン
            ├─ _CodeSection            ← 招待コード大きく表示 + コピーボタン
            ├─ ElevatedButton('共有する')  ← iOS標準シェアシート起動
            └─ TextButton('閉じる')
```

### ローディング（`InviteLinkShareCreating` State）

- 「招待リンクを作成」ボタンを `CircularProgressIndicator` に置き換える
- 他の入力要素を disabled にする

### エラー（`InviteLinkShareError` State）

- 設定画面を再表示し、上部にエラーメッセージを表示する
- 「招待リンクを作成」ボタンは再度 enabled にする

## 14.3 共有ボタン

「共有する」ボタンタップ時は Widget 側で以下を実行する:
- `share_plus` パッケージ（または `Share` API）で iOS 標準シェアシートを起動する
- 共有テキスト: 招待URL + 改行 + 「招待コード: [code]」

## 14.4 コピーボタン

Widget 側で `Clipboard.setData` を呼び出し、`ScaffoldMessenger.showSnackBar` でフィードバックを表示する。

---

# 15. Widget Key 一覧

| キー | 要素 | 説明 |
|---|---|---|
| `Key('inviteLinkShare_sheet_root')` | BottomSheet のルートContainer | テスト用ルート要素 |
| `Key('inviteLinkShare_radio_editor')` | 「編集可能」ラジオボタン | 権限選択 |
| `Key('inviteLinkShare_radio_viewer')` | 「閲覧のみ」ラジオボタン | 権限選択 |
| `Key('inviteLinkShare_chip_expires24')` | 「24時間」選択チップ | 有効期限選択 |
| `Key('inviteLinkShare_chip_expires72')` | 「72時間」選択チップ | 有効期限選択 |
| `Key('inviteLinkShare_chip_expires168')` | 「7日間」選択チップ | 有効期限選択 |
| `Key('inviteLinkShare_chip_maxUses1')` | 「1回」選択チップ | 使用回数選択 |
| `Key('inviteLinkShare_chip_maxUses5')` | 「5回」選択チップ | 使用回数選択 |
| `Key('inviteLinkShare_chip_maxUsesNull')` | 「無制限」選択チップ | 使用回数選択 |
| `Key('inviteLinkShare_button_create')` | 「招待リンクを作成」ボタン | 生成実行 |
| `Key('inviteLinkShare_text_inviteUrl')` | 招待URL表示テキスト | 結果表示 |
| `Key('inviteLinkShare_text_inviteCode')` | 招待コード表示テキスト | 結果表示 |
| `Key('inviteLinkShare_button_copyUrl')` | 「リンクをコピー」ボタン | クリップボードコピー |
| `Key('inviteLinkShare_button_copyCode')` | 「コードをコピー」ボタン | クリップボードコピー |
| `Key('inviteLinkShare_button_share')` | 「共有する」ボタン | シェアシート起動 |
| `Key('inviteLinkShare_button_close')` | 「閉じる」ボタン | BottomSheet閉じる |
| `Key('inviteLinkShare_text_error')` | エラーメッセージ表示 | エラー時のみ表示 |
| `Key('inviteLinkShare_loading')` | ローディングインジケーター | API呼び出し中 |

---

# 16. Navigation

## 遷移パターン

| 操作 | 遷移方法 | 備考 |
|---|---|---|
| 「メンバーを招待」タップ（EventDetail） | `showModalBottomSheet` | go_router のルート追加は不要。BottomSheetとして表示 |
| 「閉じる」タップ（BottomSheet内） | `Navigator.pop(context)` | BottomSheet を閉じる（go_router 管轄外） |

## Router 変更方針

- go_router のルート定義変更は不要
- BottomSheet は `showModalBottomSheet` で表示するため、ルートとしては管理しない
- F-7 Spec で暫定定義していた `/invite-link` ルートは使用しない。BottomSheet方式に変更する

**F-7 Spec との差分:**
F-7 Spec では `context.push('/invite-link')` で別画面に遷移する方針だったが、INV-4 では招待設定をBottomSheetで表示する方針に変更する。
理由: 招待設定は簡潔な3項目の選択であり、全画面遷移よりもBottomSheetの方がUX上自然である。
これに伴い F-7 の `EventDetailOpenInviteLinkDelegate` の処理を `context.push` ではなく `showModalBottomSheet` に変更する。

---

# 17. Data Flow

## 招待リンク生成フロー

1. ユーザーが概要タブの「メンバーを招待」ボタンをタップする
2. `EventDetailInviteLinkButtonPressed` が EventDetailBloc に dispatch される
3. EventDetailBloc が `EventDetailOpenInviteLinkDelegate` を State に emit する
4. EventDetailPage の BlocListener が Delegate を受け取る
5. `showModalBottomSheet` で `InviteLinkShareSheet` を表示する
6. `InviteLinkShareBloc` が `InviteLinkShareStarted` で初期化される
7. ユーザーが権限・有効期限・使用回数を選択する（各 Changed Event -> Draft 更新）
8. ユーザーが「招待リンクを作成」をタップする
9. `InviteLinkCreatePressed` -> Bloc が `InviteLinkShareCreating` を emit
10. `AuthRepository.currentUid` で UID を取得する
11. `InviteLinkShareAdapter.toCreateRequest` で API リクエストを生成する
12. `InvitationRepository.createInvitation` を呼び出す（現在はスタブ）
13. 成功: `InviteLinkShareAdapter.toResult` -> `InviteLinkShareCreated` を emit
14. Widget が結果画面（URL・コード・コピー・共有ボタン）を表示する

## コピー・共有フロー

1. ユーザーが「リンクをコピー」/「コードをコピー」をタップする
2. Widget が `Clipboard.setData` を呼び出す
3. `ScaffoldMessenger.showSnackBar` で「コピーしました」を表示する

1. ユーザーが「共有する」をタップする
2. Widget が `Share.share(text)` を呼び出す
3. iOS標準シェアシートが表示される

---

# 18. ファイル構成

## 新規追加

```
flutter/lib/features/invite_link_share/
  bloc/
    invite_link_share_bloc.dart
    invite_link_share_event.dart
    invite_link_share_state.dart
  draft/
    invite_link_share_draft.dart       # InviteLinkShareDraft, InviteLinkRole enum
  domain/
    invite_link_share_result.dart      # InviteLinkShareResult
    create_invitation_request.dart     # CreateInvitationRequest
    create_invitation_response.dart    # CreateInvitationResponse
  adapter/
    invite_link_share_adapter.dart     # toCreateRequest, toResult
  view/
    invite_link_share_sheet.dart       # BottomSheet 本体
    widgets/
      role_selector.dart               # 権限選択 UI
      expires_selector.dart            # 有効期限選択 UI
      max_uses_selector.dart           # 使用回数選択 UI
      result_view.dart                 # 生成結果表示 UI
```

## 変更対象

```
flutter/lib/features/invite_code_input/repository/
  invitation_repository.dart           # createInvitation メソッド追加
  impl/stub_invitation_repository.dart # createInvitation スタブ追加

flutter/lib/features/event_detail/
  bloc/event_detail_state.dart         # EventDetailOpenInviteLinkDelegate 追加
  bloc/event_detail_bloc.dart          # InviteLinkButtonPressed ハンドラに Delegate emit 追加
  view/event_detail_page.dart          # _handleDelegate に BottomSheet 表示処理追加

flutter/lib/app/di.dart               # InviteLinkShareBloc は BottomSheet 内で Provider するため DI 変更不要（必要に応じて確認）
```

---

# 19. 依存パッケージ

| パッケージ | 用途 | 追加要否 |
|---|---|---|
| `share_plus` | iOS標準シェアシート起動 | 新規追加 |
| `flutter/services.dart` | Clipboard API | 標準ライブラリ（追加不要） |

---

# 20. Test Scenarios

## 前提条件

- iOSシミュレーター起動済み
- シードデータにイベントが1件以上存在すること
- 現在のユーザーが owner 権限であること（スタブ設定）
- `StubInvitationRepository` に `createInvitation` スタブが実装されていること

## テストファイル

`flutter/integration_test/invite_link_share_test.dart`

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-INV4-001 | 「メンバーを招待」ボタンタップで招待設定BottomSheetが表示される | High |
| TC-INV4-002 | デフォルト設定値が正しい（編集可能・24時間・1回） | High |
| TC-INV4-003 | 権限を「閲覧のみ」に変更できる | High |
| TC-INV4-004 | 有効期限を「72時間」に変更できる | Medium |
| TC-INV4-005 | 使用回数を「無制限」に変更できる | Medium |
| TC-INV4-006 | 「招待リンクを作成」タップで生成結果が表示される | High |
| TC-INV4-007 | 生成結果に招待URLと招待コードが表示される | High |
| TC-INV4-008 | 「リンクをコピー」タップでSnackBarが表示される | Medium |
| TC-INV4-009 | 「コードをコピー」タップでSnackBarが表示される | Medium |
| TC-INV4-010 | 「閉じる」タップでBottomSheetが閉じる | Medium |
| TC-INV4-011 | API呼び出し中にローディングインジケーターが表示される | Medium |

## シナリオ詳細

### TC-INV4-001: 「メンバーを招待」ボタンタップで招待設定BottomSheetが表示される

**前提:**
- シードデータのイベントに対して現在のユーザーが owner 権限を持つ設定（スタブで `userRole = InvitationRole.owner` を返す）

**操作手順:**
1. アプリを起動する
2. イベント一覧でイベントをタップしてイベント詳細を開く
3. 概要タブの招待セクションまでスクロールする
4. `Key('overview_button_inviteLink')` をタップする

**期待結果:**
- `Key('inviteLinkShare_sheet_root')` が表示される（BottomSheet が開く）
- `Key('inviteLinkShare_button_create')` が表示される

**実装ノート:**
- ウィジェットキー: `Key('overview_button_inviteLink')`（F-7定義済み）、`Key('inviteLinkShare_sheet_root')`

---

### TC-INV4-002: デフォルト設定値が正しい（編集可能・24時間・1回）

**前提:**
- TC-INV4-001 の状態（BottomSheet が表示されている）

**操作手順:**
1. TC-INV4-001 の手順1〜4 を実行する

**期待結果:**
- `Key('inviteLinkShare_radio_editor')` が選択状態である
- `Key('inviteLinkShare_chip_expires24')` が選択状態である
- `Key('inviteLinkShare_chip_maxUses1')` が選択状態である

**実装ノート:**
- Radio / ChoiceChip の選択状態はウィジェットの `selected` プロパティで検証する

---

### TC-INV4-003: 権限を「閲覧のみ」に変更できる

**前提:**
- TC-INV4-001 の状態（BottomSheet が表示されている）

**操作手順:**
1. TC-INV4-001 の手順1〜4 を実行する
2. `Key('inviteLinkShare_radio_viewer')` をタップする

**期待結果:**
- `Key('inviteLinkShare_radio_viewer')` が選択状態になる
- `Key('inviteLinkShare_radio_editor')` が非選択状態になる

---

### TC-INV4-004: 有効期限を「72時間」に変更できる

**前提:**
- TC-INV4-001 の状態（BottomSheet が表示されている）

**操作手順:**
1. TC-INV4-001 の手順1〜4 を実行する
2. `Key('inviteLinkShare_chip_expires72')` をタップする

**期待結果:**
- `Key('inviteLinkShare_chip_expires72')` が選択状態になる
- `Key('inviteLinkShare_chip_expires24')` が非選択状態になる

---

### TC-INV4-005: 使用回数を「無制限」に変更できる

**前提:**
- TC-INV4-001 の状態（BottomSheet が表示されている）

**操作手順:**
1. TC-INV4-001 の手順1〜4 を実行する
2. `Key('inviteLinkShare_chip_maxUsesNull')` をタップする

**期待結果:**
- `Key('inviteLinkShare_chip_maxUsesNull')` が選択状態になる
- `Key('inviteLinkShare_chip_maxUses1')` が非選択状態になる

---

### TC-INV4-006: 「招待リンクを作成」タップで生成結果が表示される

**前提:**
- TC-INV4-001 の状態（BottomSheet が表示されている）
- `StubInvitationRepository.createInvitation` がダミーデータを返す

**操作手順:**
1. TC-INV4-001 の手順1〜4 を実行する
2. `Key('inviteLinkShare_button_create')` をタップする
3. ローディング完了を待つ

**期待結果:**
- `Key('inviteLinkShare_text_inviteUrl')` が表示される
- `Key('inviteLinkShare_text_inviteCode')` が表示される
- `Key('inviteLinkShare_button_copyUrl')` が表示される
- `Key('inviteLinkShare_button_copyCode')` が表示される
- `Key('inviteLinkShare_button_share')` が表示される
- `Key('inviteLinkShare_button_close')` が表示される

**実装ノート:**
- スタブは即座にレスポンスを返すため、ローディング表示は一瞬で消える可能性がある

---

### TC-INV4-007: 生成結果に招待URLと招待コードが表示される

**前提:**
- TC-INV4-006 の状態（生成結果が表示されている）

**操作手順:**
1. TC-INV4-006 の手順1〜3 を実行する

**期待結果:**
- `Key('inviteLinkShare_text_inviteUrl')` のテキストにスタブの招待URL（`https://michimark.example.com/invite/stub-token-inv4`）が含まれる
- `Key('inviteLinkShare_text_inviteCode')` のテキストにスタブの招待コード（`STB-0001`）が含まれる

---

### TC-INV4-008: 「リンクをコピー」タップでSnackBarが表示される

**前提:**
- TC-INV4-006 の状態（生成結果が表示されている）

**操作手順:**
1. TC-INV4-006 の手順1〜3 を実行する
2. `Key('inviteLinkShare_button_copyUrl')` をタップする

**期待結果:**
- SnackBar に「コピーしました」相当のメッセージが表示される

**実装ノート:**
- SnackBar のテキスト検証は `find.text('コピーしました')` 等で行う

---

### TC-INV4-009: 「コードをコピー」タップでSnackBarが表示される

**前提:**
- TC-INV4-006 の状態（生成結果が表示されている）

**操作手順:**
1. TC-INV4-006 の手順1〜3 を実行する
2. `Key('inviteLinkShare_button_copyCode')` をタップする

**期待結果:**
- SnackBar に「コピーしました」相当のメッセージが表示される

---

### TC-INV4-010: 「閉じる」タップでBottomSheetが閉じる

**前提:**
- TC-INV4-006 の状態（生成結果が表示されている）

**操作手順:**
1. TC-INV4-006 の手順1〜3 を実行する
2. `Key('inviteLinkShare_button_close')` をタップする

**期待結果:**
- `Key('inviteLinkShare_sheet_root')` が表示されなくなる（BottomSheet が閉じる）
- イベント詳細画面（概要タブ）が表示される

---

### TC-INV4-011: API呼び出し中にローディングインジケーターが表示される

**前提:**
- TC-INV4-001 の状態（BottomSheet が表示されている）

**操作手順:**
1. TC-INV4-001 の手順1〜4 を実行する
2. `Key('inviteLinkShare_button_create')` をタップする

**期待結果:**
- `Key('inviteLinkShare_loading')` が一時的に表示される（スタブのため一瞬の可能性あり）

**実装ノート:**
- スタブ実装が即座に返す場合、ローディングの検証が困難な可能性がある。その場合は `pump` 直後（settle 前）に検証するか、スタブに遅延を入れて対応する

---

# 21. 依存関係

| 依存 | 方向 | 説明 |
|---|---|---|
| INFRA-1 | INV-4が依存 | Firebase Auth UID 取得（AuthRepository） |
| INV-1 | INV-4が依存 | POST /api/invitations（現時点はスタブで代替） |
| F-7 | INV-4が依存 | EventDetailBloc の招待ボタンEvent・Delegate が定義済みであること |
| INV-3 | 独立 | 並行実施可能。ただし InvitationRepository を共有するため、メソッド追加時に競合に注意 |

---

# End of FS-invitation_link_share
