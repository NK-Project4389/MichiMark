# Feature Spec: FS-master_detail_button_layout

- **Spec ID**: FS-master_detail_button_layout
- **対応要件**: REQ-master_detail_button_layout
- **作成日**: 2026-04-16
- **ステータス**: 確定
- **対象Feature**: trans_setting / member_setting / tag_setting / action_setting（詳細画面）

---

## 1. Purpose

交通手段・メンバー・タグ・アクションの各マスター項目詳細画面について、以下のUI変更を行う。

1. AppBar右側の「保存」TextButtonを廃止する
2. フォーム最下部に「キャンセル」（OutlinedButton）と「保存」（ElevatedButton）を横並び（Row）で追加する

MarkDetail/LinkDetail/PaymentDetail（UI-5）のボタン配置パターンを踏襲し、全詳細画面の操作UIを統一する。

---

## 2. 共通変更パターン

4画面はすべて同一の変更パターンを適用する。各画面固有の差異は §3〜§6 に記載する。

### 2.1 AppBar右側保存ボタン廃止

- AppBar の `actions` に配置していた「保存」TextButton を削除する
- AppBar 左の戻るアイコン（chevron_left）は変更しない

### 2.2 フォーム最下部へのボタン配置

**変更前**
- キャンセル: AppBar左の戻るアイコン（chevron_left）で代替
- 保存: AppBar右側のTextButton

**変更後**
- AppBar右側のTextButton（保存）を削除する
- フォームの最下部（Listviewの末尾またはColumnの末尾）にボタン行を追加する
- ボタン行レイアウト:
  - 横並び（Row）・中央寄せ（MainAxisAlignment.center）
  - 左: キャンセルボタン（OutlinedButton）
  - 右: 保存ボタン（ElevatedButton）
  - 2ボタン間に適切な水平余白を設ける

**キャンセルボタンの挙動**
- タップ時: 既存の BackTapped イベントをBlocに送出する（変更なし）
- BlocListenerが `DismissDelegate` を受け取り `context.pop()` で画面を閉じる

**保存ボタンの挙動**
- タップ時: 既存の SaveTapped イベントをBlocに送出する（変更なし）
- `isSaving == true` の間は非活性（disabled）にする

---

## 3. TransSettingDetail 固有仕様

### 3.1 変更前後

| 項目 | 変更前 | 変更後 |
|---|---|---|
| AppBar actions | 「保存」TextButton | なし |
| AppBar leading | 戻るアイコン（chevron_left） | 変更なし |
| キャンセル | 戻るアイコンで代替 | フォーム最下部・左 OutlinedButton「キャンセル」|
| 保存 | AppBar右 TextButton | フォーム最下部・右 ElevatedButton「保存」|

### 3.2 BlocEvent（既存イベントを流用）

追加・変更なし。以下の既存イベントをボタン行に接続する。

- キャンセル → `TransSettingDetailBackTapped`（既存）
- 保存 → `TransSettingDetailSaveTapped`（既存）

---

## 4. MemberSettingDetail 固有仕様

### 4.1 変更前後

| 項目 | 変更前 | 変更後 |
|---|---|---|
| AppBar actions | 「保存」TextButton | なし |
| AppBar leading | 戻るアイコン（chevron_left） | 変更なし |
| キャンセル | 戻るアイコンで代替 | フォーム最下部・左 OutlinedButton「キャンセル」|
| 保存 | AppBar右 TextButton | フォーム最下部・右 ElevatedButton「保存」|

### 4.2 BlocEvent（既存イベントを流用）

追加・変更なし。以下の既存イベントをボタン行に接続する。

- キャンセル → `MemberSettingDetailBackTapped`（既存）
- 保存 → `MemberSettingDetailSaveTapped`（既存）

---

## 5. TagSettingDetail 固有仕様

### 5.1 変更前後

| 項目 | 変更前 | 変更後 |
|---|---|---|
| AppBar actions | 「保存」TextButton | なし |
| AppBar leading | 戻るアイコン（chevron_left） | 変更なし |
| キャンセル | 戻るアイコンで代替 | フォーム最下部・左 OutlinedButton「キャンセル」|
| 保存 | AppBar右 TextButton | フォーム最下部・右 ElevatedButton「保存」|

### 5.2 BlocEvent（既存イベントを流用）

追加・変更なし。以下の既存イベントをボタン行に接続する。

- キャンセル → `TagSettingDetailBackTapped`（既存）
- 保存 → `TagSettingDetailSaveTapped`（既存）

---

## 6. ActionSettingDetail 固有仕様

### 6.1 変更前後

| 項目 | 変更前 | 変更後 |
|---|---|---|
| AppBar actions | 「保存」TextButton | なし |
| AppBar leading | 戻るアイコン（chevron_left） | 変更なし |
| キャンセル | 戻るアイコンで代替 | フォーム最下部・左 OutlinedButton「キャンセル」|
| 保存 | AppBar右 TextButton | フォーム最下部・右 ElevatedButton「保存」|

### 6.2 BlocEvent（既存イベントを流用）

追加・変更なし。以下の既存イベントをボタン行に接続する。

- キャンセル → `ActionSettingDetailBackTapped`（既存）
- 保存 → `ActionSettingDetailSaveTapped`（既存）

---

## 7. State フィールド参照（保存ボタン制御）

| 画面 | State | 保存ボタン制御フィールド |
|---|---|---|
| TransSettingDetail | `TransSettingDetailLoaded` | `isSaving` |
| MemberSettingDetail | `MemberSettingDetailLoaded` | `isSaving` |
| TagSettingDetail | `TagSettingDetailLoaded` | `isSaving` |
| ActionSettingDetail | `ActionSettingDetailLoaded` | `isSaving` |

- `isSaving == true` のとき、保存ボタンを非活性にする
- State変更・フィールド追加は不要

---

## 8. Data Flow

### キャンセル操作

1. ユーザーがキャンセルボタンをタップする
2. Widget が Bloc に `BackTapped` イベントを送出する
3. Bloc が `DismissDelegate` を State に乗せる
4. BlocListener が `DismissDelegate` を受け取り `context.pop()` で画面を閉じる

### 保存操作

1. ユーザーが保存ボタンをタップする
2. Widget が Bloc に `SaveTapped` イベントを送出する
3. Bloc が `isSaving: true` を emit する（ボタンが非活性になる）
4. Bloc が保存処理を実行し、`DidSaveDelegate` または エラーを State に乗せる
5. BlocListener が `DidSaveDelegate` を受け取り `context.pop()` で画面を閉じる

---

## 9. Router変更方針

変更なし。4画面ともルート定義・遷移パスの変更は不要。

---

## 10. 実装スコープ（変更対象ファイル）

以下のViewファイルのみ変更する。BlocEvent・State・Draft・Adapter・Repositoryの変更は不要。

| ファイル | 変更内容 |
|---|---|
| `flutter/lib/features/settings/trans_setting/view/trans_setting_detail_page.dart` | AppBar actions保存ボタン削除・フォーム末尾にキャンセル/保存ボタン行追加 |
| `flutter/lib/features/settings/member_setting/view/member_setting_detail_page.dart` | 同上 |
| `flutter/lib/features/settings/tag_setting/view/tag_setting_detail_page.dart` | 同上 |
| `flutter/lib/features/settings/action_setting/view/action_setting_detail_page.dart` | 同上 |

---

## 11. Test Scenarios

### 前提条件

- iOSシミュレーターが起動済みであること
- 設定画面から各マスター項目一覧画面を開ける状態であること
- 各マスター項目が1件以上登録されていること（編集テスト用）

### テストシナリオ一覧

| ID | シナリオ名 | 対象画面 | 優先度 |
|---|---|---|---|
| TC-MDB-001 | TransSettingDetail：AppBarに「保存」ボタンが表示されないこと | TransSettingDetail | High |
| TC-MDB-002 | MemberSettingDetail：AppBarに「保存」ボタンが表示されないこと | MemberSettingDetail | High |
| TC-MDB-003 | TagSettingDetail：AppBarに「保存」ボタンが表示されないこと | TagSettingDetail | High |
| TC-MDB-004 | ActionSettingDetail：AppBarに「保存」ボタンが表示されないこと | ActionSettingDetail | High |
| TC-MDB-005 | TransSettingDetail：AppBar左に戻るアイコンが表示されること | TransSettingDetail | High |
| TC-MDB-006 | MemberSettingDetail：AppBar左に戻るアイコンが表示されること | MemberSettingDetail | High |
| TC-MDB-007 | TagSettingDetail：AppBar左に戻るアイコンが表示されること | TagSettingDetail | High |
| TC-MDB-008 | ActionSettingDetail：AppBar左に戻るアイコンが表示されること | ActionSettingDetail | High |
| TC-MDB-009 | TransSettingDetail：フォーム最下部にキャンセル/保存ボタンが横並びで表示されること | TransSettingDetail | High |
| TC-MDB-010 | MemberSettingDetail：フォーム最下部にキャンセル/保存ボタンが横並びで表示されること | MemberSettingDetail | High |
| TC-MDB-011 | TagSettingDetail：フォーム最下部にキャンセル/保存ボタンが横並びで表示されること | TagSettingDetail | High |
| TC-MDB-012 | ActionSettingDetail：フォーム最下部にキャンセル/保存ボタンが横並びで表示されること | ActionSettingDetail | High |
| TC-MDB-013 | TransSettingDetail：キャンセルタップで画面が閉じること | TransSettingDetail | High |
| TC-MDB-014 | MemberSettingDetail：キャンセルタップで画面が閉じること | MemberSettingDetail | High |
| TC-MDB-015 | TagSettingDetail：キャンセルタップで画面が閉じること | TagSettingDetail | High |
| TC-MDB-016 | ActionSettingDetail：キャンセルタップで画面が閉じること | ActionSettingDetail | High |
| TC-MDB-017 | TransSettingDetail：保存タップで保存されて画面が閉じること | TransSettingDetail | High |
| TC-MDB-018 | MemberSettingDetail：保存タップで保存されて画面が閉じること | MemberSettingDetail | High |
| TC-MDB-019 | TagSettingDetail：保存タップで保存されて画面が閉じること | TagSettingDetail | High |
| TC-MDB-020 | ActionSettingDetail：保存タップで保存されて画面が閉じること | ActionSettingDetail | High |

---

### TC-MDB-001: TransSettingDetail — AppBarに「保存」ボタンが表示されないこと

**前提:**
- 交通手段が1件以上存在する

**手順:**
1. 設定画面を開く
2. 交通手段設定をタップして一覧画面を開く
3. 一覧から任意の交通手段をタップして詳細画面を開く

**期待結果:**
- AppBar右側に「保存」テキストボタンが表示されない

**実装ノート（ウィジェットキー）:**
- `Key('transSettingDetail_appBar_saveButton')` が存在しないこと

---

### TC-MDB-002: MemberSettingDetail — AppBarに「保存」ボタンが表示されないこと

**前提:**
- メンバーが1件以上存在する

**手順:**
1. 設定画面を開く
2. メンバー設定をタップして一覧画面を開く
3. 一覧から任意のメンバーをタップして詳細画面を開く

**期待結果:**
- AppBar右側に「保存」テキストボタンが表示されない

**実装ノート（ウィジェットキー）:**
- `Key('memberSettingDetail_appBar_saveButton')` が存在しないこと

---

### TC-MDB-003: TagSettingDetail — AppBarに「保存」ボタンが表示されないこと

**前提:**
- タグが1件以上存在する

**手順:**
1. 設定画面を開く
2. タグ設定をタップして一覧画面を開く
3. 一覧から任意のタグをタップして詳細画面を開く

**期待結果:**
- AppBar右側に「保存」テキストボタンが表示されない

**実装ノート（ウィジェットキー）:**
- `Key('tagSettingDetail_appBar_saveButton')` が存在しないこと

---

### TC-MDB-004: ActionSettingDetail — AppBarに「保存」ボタンが表示されないこと

**前提:**
- アクションが1件以上存在する

**手順:**
1. 設定画面を開く
2. アクション設定をタップして一覧画面を開く
3. 一覧から任意のアクションをタップして詳細画面を開く

**期待結果:**
- AppBar右側に「保存」テキストボタンが表示されない

**実装ノート（ウィジェットキー）:**
- `Key('actionSettingDetail_appBar_saveButton')` が存在しないこと

---

### TC-MDB-005: TransSettingDetail — AppBar左に戻るアイコンが表示されること

**前提:**
- 交通手段が1件以上存在する

**手順:**
1. TransSettingDetail画面を開く

**期待結果:**
- AppBar左側に戻るアイコン（chevron_left）が表示される

**実装ノート（ウィジェットキー）:**
- `Key('transSettingDetail_appBar_backButton')` が表示されること

---

### TC-MDB-006: MemberSettingDetail — AppBar左に戻るアイコンが表示されること

**前提:**
- メンバーが1件以上存在する

**手順:**
1. MemberSettingDetail画面を開く

**期待結果:**
- AppBar左側に戻るアイコン（chevron_left）が表示される

**実装ノート（ウィジェットキー）:**
- `Key('memberSettingDetail_appBar_backButton')` が表示されること

---

### TC-MDB-007: TagSettingDetail — AppBar左に戻るアイコンが表示されること

**前提:**
- タグが1件以上存在する

**手順:**
1. TagSettingDetail画面を開く

**期待結果:**
- AppBar左側に戻るアイコン（chevron_left）が表示される

**実装ノート（ウィジェットキー）:**
- `Key('tagSettingDetail_appBar_backButton')` が表示されること

---

### TC-MDB-008: ActionSettingDetail — AppBar左に戻るアイコンが表示されること

**前提:**
- アクションが1件以上存在する

**手順:**
1. ActionSettingDetail画面を開く

**期待結果:**
- AppBar左側に戻るアイコン（chevron_left）が表示される

**実装ノート（ウィジェットキー）:**
- `Key('actionSettingDetail_appBar_backButton')` が表示されること

---

### TC-MDB-009: TransSettingDetail — フォーム最下部にキャンセル/保存ボタンが表示されること

**前提:**
- 交通手段が1件以上存在する

**手順:**
1. TransSettingDetail画面を開く
2. フォームを最下部までスクロールする

**期待結果:**
- `Key('transSettingDetail_button_cancel')` が表示される
- `Key('transSettingDetail_button_save')` が表示される
- キャンセルボタンが左・保存ボタンが右に横並びで表示される

---

### TC-MDB-010: MemberSettingDetail — フォーム最下部にキャンセル/保存ボタンが表示されること

**前提:**
- メンバーが1件以上存在する

**手順:**
1. MemberSettingDetail画面を開く
2. フォームを最下部までスクロールする

**期待結果:**
- `Key('memberSettingDetail_button_cancel')` が表示される
- `Key('memberSettingDetail_button_save')` が表示される
- キャンセルボタンが左・保存ボタンが右に横並びで表示される

---

### TC-MDB-011: TagSettingDetail — フォーム最下部にキャンセル/保存ボタンが表示されること

**前提:**
- タグが1件以上存在する

**手順:**
1. TagSettingDetail画面を開く
2. フォームを最下部までスクロールする

**期待結果:**
- `Key('tagSettingDetail_button_cancel')` が表示される
- `Key('tagSettingDetail_button_save')` が表示される
- キャンセルボタンが左・保存ボタンが右に横並びで表示される

---

### TC-MDB-012: ActionSettingDetail — フォーム最下部にキャンセル/保存ボタンが表示されること

**前提:**
- アクションが1件以上存在する

**手順:**
1. ActionSettingDetail画面を開く
2. フォームを最下部までスクロールする

**期待結果:**
- `Key('actionSettingDetail_button_cancel')` が表示される
- `Key('actionSettingDetail_button_save')` が表示される
- キャンセルボタンが左・保存ボタンが右に横並びで表示される

---

### TC-MDB-013: TransSettingDetail — キャンセルタップで画面が閉じること

**前提:**
- TransSettingDetail画面が開いている

**手順:**
1. フォームを最下部までスクロールする
2. `Key('transSettingDetail_button_cancel')` をタップする

**期待結果:**
- TransSettingDetail画面が閉じ、交通手段一覧画面（TransSettingPage）に戻る
- 変更（編集中の内容）は保存されていない

---

### TC-MDB-014: MemberSettingDetail — キャンセルタップで画面が閉じること

**前提:**
- MemberSettingDetail画面が開いている

**手順:**
1. フォームを最下部までスクロールする
2. `Key('memberSettingDetail_button_cancel')` をタップする

**期待結果:**
- MemberSettingDetail画面が閉じ、メンバー一覧画面（MemberSettingPage）に戻る
- 変更は保存されていない

---

### TC-MDB-015: TagSettingDetail — キャンセルタップで画面が閉じること

**前提:**
- TagSettingDetail画面が開いている

**手順:**
1. フォームを最下部までスクロールする
2. `Key('tagSettingDetail_button_cancel')` をタップする

**期待結果:**
- TagSettingDetail画面が閉じ、タグ一覧画面（TagSettingPage）に戻る
- 変更は保存されていない

---

### TC-MDB-016: ActionSettingDetail — キャンセルタップで画面が閉じること

**前提:**
- ActionSettingDetail画面が開いている

**手順:**
1. フォームを最下部までスクロールする
2. `Key('actionSettingDetail_button_cancel')` をタップする

**期待結果:**
- ActionSettingDetail画面が閉じ、アクション一覧画面（ActionSettingPage）に戻る
- 変更は保存されていない

---

### TC-MDB-017: TransSettingDetail — 保存タップで保存されて画面が閉じること

**前提:**
- TransSettingDetail画面が開いている

**手順:**
1. 名称フィールドを「テスト交通手段」に変更する
2. フォームを最下部までスクロールする
3. `Key('transSettingDetail_button_save')` をタップする
4. 保存完了を待つ

**期待結果:**
- TransSettingDetail画面が閉じ、交通手段一覧画面（TransSettingPage）に戻る
- 一覧に変更した内容が反映されている

---

### TC-MDB-018: MemberSettingDetail — 保存タップで保存されて画面が閉じること

**前提:**
- MemberSettingDetail画面が開いている

**手順:**
1. 名称フィールドを「テストメンバー」に変更する
2. フォームを最下部までスクロールする
3. `Key('memberSettingDetail_button_save')` をタップする
4. 保存完了を待つ

**期待結果:**
- MemberSettingDetail画面が閉じ、メンバー一覧画面（MemberSettingPage）に戻る
- 一覧に変更した内容が反映されている

---

### TC-MDB-019: TagSettingDetail — 保存タップで保存されて画面が閉じること

**前提:**
- TagSettingDetail画面が開いている

**手順:**
1. 名称フィールドを「テストタグ」に変更する
2. フォームを最下部までスクロールする
3. `Key('tagSettingDetail_button_save')` をタップする
4. 保存完了を待つ

**期待結果:**
- TagSettingDetail画面が閉じ、タグ一覧画面（TagSettingPage）に戻る
- 一覧に変更した内容が反映されている

---

### TC-MDB-020: ActionSettingDetail — 保存タップで保存されて画面が閉じること

**前提:**
- ActionSettingDetail画面が開いている

**手順:**
1. 名称フィールドを「テストアクション」に変更する
2. フォームを最下部までスクロールする
3. `Key('actionSettingDetail_button_save')` をタップする
4. 保存完了を待つ

**期待結果:**
- ActionSettingDetail画面が閉じ、アクション一覧画面（ActionSettingPage）に戻る
- 一覧に変更した内容が反映されている

---

## 12. ウィジェットキー一覧

| Key | 画面 | 種別 | 説明 |
|---|---|---|---|
| `Key('transSettingDetail_appBar_saveButton')` | TransSettingDetail | ボタン | 存在しないことを確認するためのキー（実装しない） |
| `Key('transSettingDetail_appBar_backButton')` | TransSettingDetail | ボタン | AppBar左の戻るアイコン |
| `Key('transSettingDetail_button_cancel')` | TransSettingDetail | ボタン | フォーム最下部キャンセルボタン |
| `Key('transSettingDetail_button_save')` | TransSettingDetail | ボタン | フォーム最下部保存ボタン |
| `Key('memberSettingDetail_appBar_saveButton')` | MemberSettingDetail | ボタン | 存在しないことを確認するためのキー（実装しない） |
| `Key('memberSettingDetail_appBar_backButton')` | MemberSettingDetail | ボタン | AppBar左の戻るアイコン |
| `Key('memberSettingDetail_button_cancel')` | MemberSettingDetail | ボタン | フォーム最下部キャンセルボタン |
| `Key('memberSettingDetail_button_save')` | MemberSettingDetail | ボタン | フォーム最下部保存ボタン |
| `Key('tagSettingDetail_appBar_saveButton')` | TagSettingDetail | ボタン | 存在しないことを確認するためのキー（実装しない） |
| `Key('tagSettingDetail_appBar_backButton')` | TagSettingDetail | ボタン | AppBar左の戻るアイコン |
| `Key('tagSettingDetail_button_cancel')` | TagSettingDetail | ボタン | フォーム最下部キャンセルボタン |
| `Key('tagSettingDetail_button_save')` | TagSettingDetail | ボタン | フォーム最下部保存ボタン |
| `Key('actionSettingDetail_appBar_saveButton')` | ActionSettingDetail | ボタン | 存在しないことを確認するためのキー（実装しない） |
| `Key('actionSettingDetail_appBar_backButton')` | ActionSettingDetail | ボタン | AppBar左の戻るアイコン |
| `Key('actionSettingDetail_button_cancel')` | ActionSettingDetail | ボタン | フォーム最下部キャンセルボタン |
| `Key('actionSettingDetail_button_save')` | ActionSettingDetail | ボタン | フォーム最下部保存ボタン |

---

# End of Spec
