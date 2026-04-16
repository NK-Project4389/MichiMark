# Feature Spec: FS-invitation_ui_placement

- **Spec ID**: FS-invitation_ui_placement
- **要件書**: REQ-invitation_ui_placement
- **作成日**: 2026-04-16
- **担当**: architect
- **ステータス**: 確定
- **種別**: 機能追加（F-7）
- **関連Spec**: FS-invitation_code_input（INV-3）、INV-4（Spec未作成）

---

# 1. Feature Overview

## Feature Name

InvitationUIPlacement（イベント招待機能 UI配置）

## Purpose

イベント詳細画面の概要タブに招待機能への導線ボタンを配置する。
イベントオーナーは招待リンク生成・共有（INV-4）へ、それ以外のユーザー（editor / viewer / 未参加）は招待コード入力（INV-3）へ直接アクセスできるようにする。

## 設計判断: 配置場所

要件書に記載された2案（概要タブ内 / AppBar）のうち、**概要タブ内配置**を採用する。

理由:
- 既存AppBarにはイベント名・削除ボタンが配置済みであり、追加アイコンのスペースが制限される
- 概要タブの `_OverviewTabContent` は `BasicInfoView` + `EventDetailOverviewPage` のセクション構造であり、招待ボタンセクションを末尾に自然に追加できる
- 招待はイベントコンテキスト内の操作であり、概要タブ内に配置することでユーザーが対象イベントを確認しながら操作できる

## Scope

含むもの
- `EventDetailPage`（`event_detail_page.dart`）の `_OverviewTabContent` に招待ボタンセクションを追加
- `EventDetailBloc` に招待ボタンタップEventと遷移Delegateを追加
- 権限別表示制御（owner → 招待リンク生成ボタン、editor/viewer/未参加 → 招待コード入力ボタン）
- `EventDetailLoaded.userRole` フィールドの追加（権限情報をStateで保持）

含まないもの
- 招待リンク生成・共有ロジック本体（INV-4のスコープ）
- 招待コード入力ロジック本体（INV-3実装済み）
- `EventListPage` の既存「招待コードで参加」ボタンの削除・変更
- 招待メンバー一覧表示

---

# 2. Feature Responsibility

- `EventDetailBloc` が `EventDetailLoaded.userRole` を保持し、招待ボタンの表示制御に使用する
- 招待ボタンタップ時はDelegateをStateに乗せてPageに通知する
- PageのBlocListenerがDelegateを受け取り `context.push()` または `context.go()` で画面遷移する
- 権限情報（`userRole`）はEventDomainまたは招待情報から取得する（詳細は§7参照）

---

# 3. State Structure

## 既存 EventDetailLoaded への追加フィールド

| フィールド | 型 | 説明 |
|---|---|---|
| `userRole` | `InvitationRole?` | 現在のユーザーの権限。null は権限情報未取得または未参加 |

## InvitationRole（新規 enum）

```
enum InvitationRole { owner, editor, viewer }
```

- `owner`: 招待リンク生成ボタンを表示
- `editor` / `viewer`: 招待コード入力ボタンを表示
- `null`（未参加・未取得）: 招待コード入力ボタンを表示（ownerでないと判断）

## 招待ボタン表示ロジック

| userRole | 表示するボタン |
|---|---|
| `owner` | 「メンバーを招待」ボタンのみ |
| `editor` | 「招待コードを入力」ボタンのみ |
| `viewer` | 「招待コードを入力」ボタンのみ |
| `null` | 「招待コードを入力」ボタンのみ |

---

# 4. Draft Model

既存の `EventDetailDraft` に変更なし。招待ボタンは Draft を持たない（表示制御のみ）。

---

# 5. Domain Model

## InvitationRole

権限を表す新規 enum。Domain 層に配置する。

| 値 | 説明 |
|---|---|
| `owner` | イベント作成者 |
| `editor` | 編集権限を持つ参加者 |
| `viewer` | 閲覧権限のみの参加者 |

## userRole 取得方針

`EventDetailStarted` 発火時（または `EventDetailCachedEventUpdateRequested` 後）に `userRole` を解決する。

取得元の優先順位:
1. `EventDomain` にロール情報が含まれる場合はそこから取得する
2. `EventDomain` にロール情報がない場合は、Firebase Auth の uid と EventDomain のメンバー情報を照合して判定する
3. 判定できない場合は `null`（招待コード入力ボタンを表示）

実装時にEventDomainのロール管理状況を確認し、最適な取得方法を選択すること。

---

# 6. Projection Model

本Specはプロジェクションを変更しない。
招待ボタンの表示制御は `EventDetailLoaded.userRole` を直接Widgetが参照する。

---

# 7. Adapter

本Specは新規アダプターを追加しない。

---

# 8. Events

既存の `EventDetailEvent` に以下を追加する。

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `EventDetailInviteLinkButtonPressed` | 「メンバーを招待」ボタンタップ時（owner） | INV-4招待設定シートへの遷移意図をDelegateで通知する |
| `EventDetailInviteCodeButtonPressed` | 「招待コードを入力」ボタンタップ時（非owner） | INV-3招待コード入力画面への遷移意図をDelegateで通知する |

---

# 9. Delegate

既存の `EventDetailDelegate` に以下を追加する。

| Delegate名 | 遷移先 | 説明 |
|---|---|---|
| `EventDetailOpenInviteLinkDelegate` | INV-4 招待設定シート（`context.push('/invite-link')` 相当） | ownerが「メンバーを招待」をタップしたとき |
| `EventDetailOpenInviteCodeInputDelegate` | `/invite-code`（INV-3 既存ルート） | 非ownerが「招待コードを入力」をタップしたとき |

## Delegate 処理

`EventDetailPage._handleDelegate` に以下を追加する:

- `EventDetailOpenInviteLinkDelegate` → `context.push('/invite-link')` （INV-4ルートが確定次第更新）
- `EventDetailOpenInviteCodeInputDelegate` → `context.push('/invite-code')`

---

# 10. Bloc Responsibility

## EventDetailInviteLinkButtonPressed
1. `EventDetailOpenInviteLinkDelegate` をStateに乗せてemitする

## EventDetailInviteCodeButtonPressed
1. `EventDetailOpenInviteCodeInputDelegate` をStateに乗せてemitする

禁止事項:
- Bloc内で直接 `context.push()` / `context.go()` を呼び出すこと
- 招待処理のビジネスロジックをBlocに実装すること（INV-4のスコープ）

---

# 11. View

## 概要タブ（`_OverviewTabContent`）への追加

既存の `_OverviewTabContent` の末尾に招待ボタンセクションを追加する。

```
SingleChildScrollView
  └─ Column
       ├─ _SectionLabel('基本情報')
       ├─ BasicInfoView
       ├─ Divider
       ├─ _SectionLabel('集計')
       ├─ EventDetailOverviewPage
       ├─ Divider          ← 新規追加
       └─ _InvitationSection  ← 新規追加
```

## `_InvitationSection` Widget仕様

- `EventDetailBloc` の `EventDetailLoaded.userRole` を参照して表示を切り替える
- `userRole == InvitationRole.owner` の場合: 「メンバーを招待」ボタンを表示
- それ以外の場合: 「招待コードを入力」ボタンを表示
- ボタンスタイル: `OutlinedButton` または `TextButton`（設計憲章のUI一貫性に従う。MarkDetailの既存ボタンスタイルを参考にすること）

## Widget Key 一覧

| キー | 要素 | 説明 |
|---|---|---|
| `Key('overview_section_invitation')` | `_InvitationSection` のルートContainer | セクション全体 |
| `Key('overview_button_inviteLink')` | 「メンバーを招待」ボタン | ownerにのみ表示 |
| `Key('overview_button_inviteCodeInput')` | 「招待コードを入力」ボタン | 非ownerにのみ表示 |

---

# 12. Navigation

## 遷移パターン

| 操作 | 遷移方法 | 遷移先 |
|---|---|---|
| 「メンバーを招待」タップ（owner） | `context.push('/invite-link')` | INV-4 招待設定シート（ルートはINV-4 Spec確定時に更新） |
| 「招待コードを入力」タップ（非owner） | `context.push('/invite-code')` | `InviteCodeInputPage`（INV-3 既存実装） |

`context.push()` を使用する理由: 招待操作後にEventDetail画面に戻ることが期待されるため（画面スタックを保持する）。

---

# 13. Router変更方針

- `/invite-code` ルートはINV-3で既に実装済み。変更不要。
- `/invite-link` ルートはINV-4のSpecで定義・実装する。本Specでは暫定パスとして定義し、INV-4確定後に更新する。

---

# 14. Data Flow

```
ユーザーが概要タブを表示
  ↓
EventDetailLoaded.userRole を参照
  ↓
_InvitationSection がuserRoleに応じてボタンを表示

「メンバーを招待」タップ（owner）
  ↓
EventDetailInviteLinkButtonPressed → EventDetailBloc
  ↓
EventDetailOpenInviteLinkDelegate をStateにemit
  ↓
EventDetailPage._handleDelegate が受け取り
  ↓
context.push('/invite-link') → INV-4 招待設定シート

「招待コードを入力」タップ（非owner）
  ↓
EventDetailInviteCodeButtonPressed → EventDetailBloc
  ↓
EventDetailOpenInviteCodeInputDelegate をStateにemit
  ↓
EventDetailPage._handleDelegate が受け取り
  ↓
context.push('/invite-code') → InviteCodeInputPage（INV-3）
```

---

# 15. ファイル変更範囲

変更対象:
- `flutter/lib/features/event_detail/bloc/event_detail_event.dart` — Event 2件追加
- `flutter/lib/features/event_detail/bloc/event_detail_state.dart` — Delegate 2件追加・`EventDetailLoaded.userRole` フィールド追加
- `flutter/lib/features/event_detail/bloc/event_detail_bloc.dart` — Event handler 2件追加・起動時の `userRole` 解決ロジック追加
- `flutter/lib/features/event_detail/view/event_detail_page.dart` — `_OverviewTabContent` に `_InvitationSection` 追加・`_handleDelegate` に遷移処理追加

新規追加:
- `flutter/lib/domain/invitation/invitation_role.dart` — `InvitationRole` enum

---

# 16. Test Scenarios

## 前提条件

- iOSシミュレーター起動済み
- シードデータにイベントが1件以上存在すること
- テスト用のユーザーロール設定（スタブ/モックで制御）

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-IUP-001 | owner権限でイベント詳細を開くと「メンバーを招待」ボタンが表示される | High |
| TC-IUP-002 | owner権限で「招待コードを入力」ボタンが表示されない | High |
| TC-IUP-003 | editor/viewer権限でイベント詳細を開くと「招待コードを入力」ボタンが表示される | High |
| TC-IUP-004 | editor/viewer権限で「メンバーを招待」ボタンが表示されない | High |
| TC-IUP-005 | 「招待コードを入力」ボタンをタップすると招待コード入力画面へ遷移する | High |
| TC-IUP-006 | 招待コード入力画面からEventDetail画面に戻れる | Medium |
| TC-IUP-007 | userRole未取得（null）のとき「招待コードを入力」ボタンが表示される | Medium |

## シナリオ詳細

### TC-IUP-001: owner権限でイベント詳細を開くと「メンバーを招待」ボタンが表示される

**前提:**
- シードデータのイベントに対して現在のユーザーが owner 権限を持つ設定になっていること（スタブで `userRole = InvitationRole.owner` を返す）

**操作手順:**
1. アプリを起動する
2. イベント一覧でイベントをタップしてイベント詳細を開く
3. 概要タブが表示されていることを確認する（デフォルトタブ）
4. 画面を下にスクロールする

**期待結果:**
- `Key('overview_section_invitation')` が表示される
- `Key('overview_button_inviteLink')` が表示される

**実装ノート:**
- ウィジェットキー: `Key('overview_section_invitation')` / `Key('overview_button_inviteLink')`
- スクロールが必要な場合: `tester.drag` で下スクロール後に確認する

---

### TC-IUP-002: owner権限で「招待コードを入力」ボタンが表示されない

**前提:**
- TC-IUP-001 と同じ（owner権限）

**操作手順:**
1. TC-IUP-001 の手順1〜4 と同じ

**期待結果:**
- `Key('overview_button_inviteCodeInput')` が表示されない（`findsNothing`）

---

### TC-IUP-003: editor/viewer権限でイベント詳細を開くと「招待コードを入力」ボタンが表示される

**前提:**
- 現在のユーザーが editor または viewer 権限を持つ設定になっていること（スタブで `userRole = InvitationRole.editor` を返す）

**操作手順:**
1. アプリを起動する
2. イベント一覧でイベントをタップしてイベント詳細を開く
3. 概要タブを表示する
4. 画面を下にスクロールする

**期待結果:**
- `Key('overview_section_invitation')` が表示される
- `Key('overview_button_inviteCodeInput')` が表示される

---

### TC-IUP-004: editor/viewer権限で「メンバーを招待」ボタンが表示されない

**前提:**
- TC-IUP-003 と同じ（editor権限）

**操作手順:**
1. TC-IUP-003 の手順1〜4 と同じ

**期待結果:**
- `Key('overview_button_inviteLink')` が表示されない（`findsNothing`）

---

### TC-IUP-005: 「招待コードを入力」ボタンをタップすると招待コード入力画面へ遷移する

**前提:**
- editor 権限（または userRole = null）の状態でイベント詳細が表示されていること

**操作手順:**
1. 概要タブの招待セクションまでスクロールする
2. `Key('overview_button_inviteCodeInput')` をタップする

**期待結果:**
- `Key('invite_code_text_field')` が表示される（招待コード入力画面 INV-3 に遷移）

**実装ノート:**
- `Key('invite_code_text_field')` は `FS-invitation_code_input` で定義済み
- `context.push()` により EventDetail 画面は画面スタックに残る

---

### TC-IUP-006: 招待コード入力画面からEventDetail画面に戻れる

**前提:**
- TC-IUP-005 の状態（招待コード入力画面が表示されている）

**操作手順:**
1. 招待コード入力画面の戻るボタン（AppBarの `<` アイコン）をタップする

**期待結果:**
- イベント詳細画面（概要タブ）に戻る
- `Key('overview_section_invitation')` が再度表示される

---

### TC-IUP-007: userRole未取得（null）のとき「招待コードを入力」ボタンが表示される

**前提:**
- スタブで `userRole = null` を返す設定

**操作手順:**
1. アプリを起動する
2. イベント一覧でイベントをタップしてイベント詳細を開く
3. 概要タブを表示する
4. 画面を下にスクロールする

**期待結果:**
- `Key('overview_button_inviteCodeInput')` が表示される
- `Key('overview_button_inviteLink')` が表示されない（`findsNothing`）
