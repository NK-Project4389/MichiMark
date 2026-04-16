# Feature Spec: FS-master_list_fab_button

- **Spec ID**: FS-master_list_fab_button
- **対応要件**: REQ-master_list_fab_button
- **作成日**: 2026-04-16
- **ステータス**: 確定
- **対象Feature**: trans_setting / member_setting / tag_setting / action_setting（一覧画面）

---

## 1. Purpose

交通手段・メンバー・タグ・アクションの各マスター項目一覧画面について、以下のUI変更を行う。

1. AppBar右側の「＋」IconButtonを削除する
2. `Scaffold.floatingActionButton` に「＋」FABを追加する

MichiInfo等の他の一覧画面と新規作成ボタンの配置を統一し、ユーザーが同じ操作パターンで使えるようにする。

---

## 2. 共通変更パターン

4画面はすべて同一の変更パターンを適用する。

### 2.1 AppBar actionsの「＋」ボタン削除

- AppBar の `actions` に配置していた `IconButton`（Icons.add）を削除する
- AppBar 自体・タイトル・その他の actions は変更しない

### 2.2 FABの追加

- `Scaffold.floatingActionButton` に FAB を配置する

| 項目 | 値 |
|---|---|
| アイコン | `Icons.add` |
| 背景色 | `Color(0xFFF59E0B)`（オレンジ・テーマカラー） |
| アイコン色 | 白（`Colors.white`） |
| タップ動作 | 従来のAppBar「＋」ボタンと同じイベント（AddTapped）を送出する |

### 2.3 FABタップ時の挙動

- 従来の `AddTapped` イベントをBlocに送出する（変更なし）
- BlocListener が `OpenNewDelegate` を受け取り詳細画面（新規作成モード）に遷移する

---

## 3. TransSetting 固有仕様

### 3.1 変更前後

| 項目 | 変更前 | 変更後 |
|---|---|---|
| AppBar actions | `IconButton(Icons.add)` → `TransSettingAddTapped` | なし |
| floatingActionButton | なし | FAB（オレンジ・Icons.add） |

### 3.2 BlocEvent（既存イベントを流用）

追加・変更なし。FABに以下の既存イベントを接続する。

- FABタップ → `TransSettingAddTapped`（既存）

---

## 4. MemberSetting 固有仕様

### 4.1 変更前後

| 項目 | 変更前 | 変更後 |
|---|---|---|
| AppBar actions | `IconButton(Icons.add)` → `MemberSettingAddTapped` | なし |
| floatingActionButton | なし | FAB（オレンジ・Icons.add） |

### 4.2 BlocEvent（既存イベントを流用）

追加・変更なし。FABに以下の既存イベントを接続する。

- FABタップ → `MemberSettingAddTapped`（既存）

---

## 5. TagSetting 固有仕様

### 5.1 変更前後

| 項目 | 変更前 | 変更後 |
|---|---|---|
| AppBar actions | `IconButton(Icons.add)` → `TagSettingAddTapped` | なし |
| floatingActionButton | なし | FAB（オレンジ・Icons.add） |

### 5.2 BlocEvent（既存イベントを流用）

追加・変更なし。FABに以下の既存イベントを接続する。

- FABタップ → `TagSettingAddTapped`（既存）

---

## 6. ActionSetting 固有仕様

### 6.1 変更前後

| 項目 | 変更前 | 変更後 |
|---|---|---|
| AppBar actions | `IconButton(Icons.add)` → `ActionSettingAddTapped` | なし |
| floatingActionButton | なし | FAB（オレンジ・Icons.add） |

### 6.2 BlocEvent（既存イベントを流用）

追加・変更なし。FABに以下の既存イベントを接続する。

- FABタップ → `ActionSettingAddTapped`（既存）

---

## 7. Data Flow

### FABタップ（新規作成）

1. ユーザーが画面右下のFABをタップする
2. Widget が Bloc に `AddTapped` イベントを送出する
3. Bloc が `OpenNewDelegate` を State に乗せる
4. BlocListener が `OpenNewDelegate` を受け取り詳細画面（新規作成モード）に遷移する

---

## 8. Router変更方針

変更なし。4画面ともルート定義・遷移パスの変更は不要。FABタップ後の遷移先は既存と同じ詳細画面（新規作成モード）。

---

## 9. 実装スコープ（変更対象ファイル）

以下のViewファイルのみ変更する。BlocEvent・State・Draft・Adapter・Repositoryの変更は不要。

| ファイル | 変更内容 |
|---|---|
| `flutter/lib/features/settings/trans_setting/view/trans_setting_page.dart` | AppBar actions の「＋」削除・Scaffold.floatingActionButton にFAB追加 |
| `flutter/lib/features/settings/member_setting/view/member_setting_page.dart` | 同上 |
| `flutter/lib/features/settings/tag_setting/view/tag_setting_page.dart` | 同上 |
| `flutter/lib/features/settings/action_setting/view/action_setting_page.dart` | 同上 |

---

## 10. Test Scenarios

### 前提条件

- iOSシミュレーターが起動済みであること
- 設定画面から各マスター項目一覧画面を開ける状態であること

### テストシナリオ一覧

| ID | シナリオ名 | 対象画面 | 優先度 |
|---|---|---|---|
| TC-FAB-001 | TransSetting：AppBar右側に「＋」ボタンが表示されないこと | TransSettingPage | High |
| TC-FAB-002 | MemberSetting：AppBar右側に「＋」ボタンが表示されないこと | MemberSettingPage | High |
| TC-FAB-003 | TagSetting：AppBar右側に「＋」ボタンが表示されないこと | TagSettingPage | High |
| TC-FAB-004 | ActionSetting：AppBar右側に「＋」ボタンが表示されないこと | ActionSettingPage | High |
| TC-FAB-005 | TransSetting：画面右下にオレンジ色のFABが表示されること | TransSettingPage | High |
| TC-FAB-006 | MemberSetting：画面右下にオレンジ色のFABが表示されること | MemberSettingPage | High |
| TC-FAB-007 | TagSetting：画面右下にオレンジ色のFABが表示されること | TagSettingPage | High |
| TC-FAB-008 | ActionSetting：画面右下にオレンジ色のFABが表示されること | ActionSettingPage | High |
| TC-FAB-009 | TransSetting：FABタップで新規作成画面が開くこと | TransSettingPage | High |
| TC-FAB-010 | MemberSetting：FABタップで新規作成画面が開くこと | MemberSettingPage | High |
| TC-FAB-011 | TagSetting：FABタップで新規作成画面が開くこと | TagSettingPage | High |
| TC-FAB-012 | ActionSetting：FABタップで新規作成画面が開くこと | ActionSettingPage | High |

---

### TC-FAB-001: TransSetting — AppBar右側に「＋」ボタンが表示されないこと

**手順:**
1. 設定画面を開く
2. 交通手段設定をタップして一覧画面を開く

**期待結果:**
- AppBar右側に「＋」アイコンボタンが表示されない

**実装ノート（ウィジェットキー）:**
- `Key('transSetting_appBar_addButton')` が存在しないこと

---

### TC-FAB-002: MemberSetting — AppBar右側に「＋」ボタンが表示されないこと

**手順:**
1. 設定画面を開く
2. メンバー設定をタップして一覧画面を開く

**期待結果:**
- AppBar右側に「＋」アイコンボタンが表示されない

**実装ノート（ウィジェットキー）:**
- `Key('memberSetting_appBar_addButton')` が存在しないこと

---

### TC-FAB-003: TagSetting — AppBar右側に「＋」ボタンが表示されないこと

**手順:**
1. 設定画面を開く
2. タグ設定をタップして一覧画面を開く

**期待結果:**
- AppBar右側に「＋」アイコンボタンが表示されない

**実装ノート（ウィジェットキー）:**
- `Key('tagSetting_appBar_addButton')` が存在しないこと

---

### TC-FAB-004: ActionSetting — AppBar右側に「＋」ボタンが表示されないこと

**手順:**
1. 設定画面を開く
2. アクション設定をタップして一覧画面を開く

**期待結果:**
- AppBar右側に「＋」アイコンボタンが表示されない

**実装ノート（ウィジェットキー）:**
- `Key('actionSetting_appBar_addButton')` が存在しないこと

---

### TC-FAB-005: TransSetting — 画面右下にオレンジ色のFABが表示されること

**手順:**
1. 設定画面を開く
2. 交通手段設定をタップして一覧画面を開く

**期待結果:**
- 画面右下にFABが表示される
- FABにオレンジ色の背景（`Color(0xFFF59E0B)`）が適用されている
- FABに「＋」アイコンが表示される

**実装ノート（ウィジェットキー）:**
- `Key('transSetting_fab_add')` が表示されること

---

### TC-FAB-006: MemberSetting — 画面右下にオレンジ色のFABが表示されること

**手順:**
1. 設定画面を開く
2. メンバー設定をタップして一覧画面を開く

**期待結果:**
- 画面右下にFABが表示される
- FABにオレンジ色の背景が適用されている
- FABに「＋」アイコンが表示される

**実装ノート（ウィジェットキー）:**
- `Key('memberSetting_fab_add')` が表示されること

---

### TC-FAB-007: TagSetting — 画面右下にオレンジ色のFABが表示されること

**手順:**
1. 設定画面を開く
2. タグ設定をタップして一覧画面を開く

**期待結果:**
- 画面右下にFABが表示される
- FABにオレンジ色の背景が適用されている
- FABに「＋」アイコンが表示される

**実装ノート（ウィジェットキー）:**
- `Key('tagSetting_fab_add')` が表示されること

---

### TC-FAB-008: ActionSetting — 画面右下にオレンジ色のFABが表示されること

**手順:**
1. 設定画面を開く
2. アクション設定をタップして一覧画面を開く

**期待結果:**
- 画面右下にFABが表示される
- FABにオレンジ色の背景が適用されている
- FABに「＋」アイコンが表示される

**実装ノート（ウィジェットキー）:**
- `Key('actionSetting_fab_add')` が表示されること

---

### TC-FAB-009: TransSetting — FABタップで新規作成画面が開くこと

**手順:**
1. 交通手段設定一覧画面を開く
2. `Key('transSetting_fab_add')` をタップする

**期待結果:**
- 交通手段詳細画面（TransSettingDetailPage）が新規作成モードで開く
- 名称フィールドが空の状態で表示される

**実装ノート（ウィジェットキー）:**
- `Key('transSettingDetail_button_save')` が表示されること（詳細画面が開いたことの確認）

---

### TC-FAB-010: MemberSetting — FABタップで新規作成画面が開くこと

**手順:**
1. メンバー設定一覧画面を開く
2. `Key('memberSetting_fab_add')` をタップする

**期待結果:**
- メンバー詳細画面（MemberSettingDetailPage）が新規作成モードで開く
- 名称フィールドが空の状態で表示される

**実装ノート（ウィジェットキー）:**
- `Key('memberSettingDetail_button_save')` が表示されること（詳細画面が開いたことの確認）

---

### TC-FAB-011: TagSetting — FABタップで新規作成画面が開くこと

**手順:**
1. タグ設定一覧画面を開く
2. `Key('tagSetting_fab_add')` をタップする

**期待結果:**
- タグ詳細画面（TagSettingDetailPage）が新規作成モードで開く
- 名称フィールドが空の状態で表示される

**実装ノート（ウィジェットキー）:**
- `Key('tagSettingDetail_button_save')` が表示されること（詳細画面が開いたことの確認）

---

### TC-FAB-012: ActionSetting — FABタップで新規作成画面が開くこと

**手順:**
1. アクション設定一覧画面を開く
2. `Key('actionSetting_fab_add')` をタップする

**期待結果:**
- アクション詳細画面（ActionSettingDetailPage）が新規作成モードで開く
- 名称フィールドが空の状態で表示される

**実装ノート（ウィジェットキー）:**
- `Key('actionSettingDetail_button_save')` が表示されること（詳細画面が開いたことの確認）

---

## 11. ウィジェットキー一覧

| Key | 画面 | 種別 | 説明 |
|---|---|---|---|
| `Key('transSetting_appBar_addButton')` | TransSettingPage | ボタン | 存在しないことを確認するためのキー（実装しない） |
| `Key('transSetting_fab_add')` | TransSettingPage | FAB | 新規作成FAB |
| `Key('memberSetting_appBar_addButton')` | MemberSettingPage | ボタン | 存在しないことを確認するためのキー（実装しない） |
| `Key('memberSetting_fab_add')` | MemberSettingPage | FAB | 新規作成FAB |
| `Key('tagSetting_appBar_addButton')` | TagSettingPage | ボタン | 存在しないことを確認するためのキー（実装しない） |
| `Key('tagSetting_fab_add')` | TagSettingPage | FAB | 新規作成FAB |
| `Key('actionSetting_appBar_addButton')` | ActionSettingPage | ボタン | 存在しないことを確認するためのキー（実装しない） |
| `Key('actionSetting_fab_add')` | ActionSettingPage | FAB | 新規作成FAB |

> TC-FAB-009〜012でのウィジェットキー（詳細画面側）は FS-master_detail_button_layout.md のキー一覧を参照すること。

---

# End of Spec
