# Feature Spec: BasicInfo 参照/編集モード切替UI

- **Spec ID**: FS-basic_info_tap_to_edit
- **要件ID**: REQ-basic_info_tap_to_edit
- **作成日**: 2026-04-12
- **担当**: architect
- **ステータス**: 確定
- **対象タスク**: T-222 UI-2

---

## 1. Feature Overview

### Feature Name

BasicInfo タップ編集モード切替

### Purpose

BasicInfoセクションの参照モード全体をタップ可能にし、編集アイコンを廃止する。
セクション全体にTeal薄背景と「タップして編集」ヒントテキストを加えることで、タップで編集できることをユーザーが直感的に把握できるUIに改善する。

### Scope

含むもの
- `_BasicInfoReadView` のスタイル変更（Teal薄背景・「タップして編集」ヒントテキスト追加）
- `_BasicInfoReadView` 全体をタップ可能にする（GestureDetector）
- `IconButton(Icons.edit)` の廃止
- `_BasicInfoForm` の保存・キャンセルボタン配置をインライン（フォーム下部）に変更
- ウィジェットキーの追加（テスト対応）

含まないもの
- BasicInfo以外のセクションのモード切替
- 編集フォーム内の入力フィールドの変更
- Bloc・Draft・Eventの変更

---

## 2. Feature Responsibility

このFeatureの責務（変更なし）

- Draft所有
- Draft更新
- Domain生成・更新（Adapter経由）

変更対象はView層（`basic_info_view.dart`）のみ。
BlocおよびDraftは変更しない。

---

## 3. State Structure

変更なし。既存の `BasicInfoLoaded` をそのまま使用する。

### 参照情報

| フィールド | 型 | 説明 |
|---|---|---|
| `draft.isEditing` | `bool` | 参照モード（false）と編集モード（true）の切り替えフラグ |
| `isSaving` | `bool` | DB保存処理中フラグ（保存ボタンのローディング表示に使用） |

---

## 4. Draft Model

変更なし。`BasicInfoDraft.isEditing` フラグを参照/編集モード切替に使用する。

---

## 5. BLoC Events

Specに記載するEventはView層から発火されるもののみ。すべて既存実装済み。

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `BasicInfoEditModeEntered` | 参照モードのセクション全体タップ時 | `isEditing` を true に更新。`originalDraft` を保存 |
| `BasicInfoSavePressed` | 編集モードの保存ボタンタップ時 | DBに保存後、`isEditing` を false に更新 |
| `BasicInfoEditCancelled` | 編集モードのキャンセルボタンタップ時 | `originalDraft` に復元し、`isEditing` を false に更新 |

---

## 6. View 変更仕様

### 6.1 `_BasicInfoReadView` の変更

#### 廃止
- `Stack + Positioned` による `IconButton(Icons.edit)` の配置を削除する

#### 追加
- セクション全体を `GestureDetector` で包み、`onTap` で `BasicInfoEditModeEntered` を発火する
- セクション全体の背景色を薄いTeal（`Color(0xFFE8F4F8)` 相当）で囲む
  - 実装上は `Container` または `DecoratedBox` でラップし、`color` または `decoration` に指定する
- セクション下部（フィールド群の末尾）に「タップして編集」テキストを追加する
  - スタイル: `bodySmall`・色は `onSurfaceVariant` 相当・中央揃えまたは右揃え

#### ウィジェットキー
| キー | 対象ウィジェット |
|---|---|
| `Key('basicInfoRead_container_section')` | GestureDetector（タップ可能なセクション全体のコンテナ） |
| `Key('basicInfoRead_text_tapHint')` | 「タップして編集」ヒントテキスト |

### 6.2 `_BasicInfoForm` の変更

#### 変更
- 保存・キャンセルボタンを `Stack + Positioned` による右下フローティング配置から、フォームListViewの末尾にインライン配置に変更する
  - `ListView` の末尾アイテムとして `Row（キャンセル / 保存）` を追加する
  - `ListView` の `padding` を `EdgeInsets.only(bottom: 80)` から適切なインラインパディングに変更する

#### ウィジェットキー
| キー | 対象ウィジェット |
|---|---|
| `Key('basicInfoForm_button_cancel')` | キャンセルボタン |
| `Key('basicInfoForm_button_save')` | 保存ボタン |

---

## 7. Data Flow

変更なし。モード切替に関するフローのみ記載する。

- ユーザーが参照モードのセクションをタップ
  → `BasicInfoEditModeEntered` イベント発火
  → Blocが `isEditing = true` に更新し、`originalDraft` を保持
  → `BasicInfoLoaded` のStateが更新される
  → BlocBuilderが検知し、`_BasicInfoReadView` から `_BasicInfoForm` に切り替わる

- ユーザーが保存ボタンをタップ
  → `BasicInfoSavePressed` イベント発火
  → BlocがDB保存後、`isEditing = false` に更新
  → BlocBuilderが検知し、`_BasicInfoForm` から `_BasicInfoReadView` に切り替わる

- ユーザーがキャンセルボタンをタップ
  → `BasicInfoEditCancelled` イベント発火
  → Blocが `originalDraft` に復元し、`isEditing = false` に更新
  → BlocBuilderが検知し、`_BasicInfoForm` から `_BasicInfoReadView` に切り替わる

---

## 8. Navigation

変更なし。

---

## 9. SwiftUI版との対応

| Flutter Feature | 対応SwiftUI Reducer |
|---|---|
| `basic_info` | BasicInfoReducer |

SwiftUI版でも編集アイコンを廃止してセクションタップで編集モードに入る設計を採用していたため、本変更はその設計思想を継承する。

---

## 16. Test Scenarios

### 前提条件

- iOSシミュレーターが起動済みであること
- テスト用イベントが1件以上存在すること（またはテスト内で新規作成すること）
- BasicInfoタブが表示された状態からテストを開始すること

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-BTE-001 | BasicInfoセクションに編集アイコンが表示されないこと | High |
| TC-BTE-002 | 参照モード時にTeal薄背景が表示されること | High |
| TC-BTE-003 | 参照モード時に「タップして編集」テキストが表示されること | High |
| TC-BTE-004 | 参照モードのセクションをタップすると編集モードに切り替わること | High |
| TC-BTE-005 | 編集モード時にフォーム下部にキャンセル・保存ボタンが表示されること | High |
| TC-BTE-006 | キャンセルボタンをタップすると参照モードに戻ること | High |
| TC-BTE-007 | 保存ボタンをタップすると保存されて参照モードに戻ること | High |

---

### シナリオ詳細

#### TC-BTE-001: BasicInfoセクションに編集アイコンが表示されないこと

**前提:**
- BasicInfoタブが参照モードで表示されている

**操作手順:**
1. BasicInfoタブを表示する

**期待結果:**
- `Icons.edit` を持つ `IconButton` が画面上に存在しない

**実装ノート（ウィジェットキー）:**
- 確認対象: `find.byIcon(Icons.edit)` が `findsNothing`

---

#### TC-BTE-002: 参照モード時にTeal薄背景が表示されること

**前提:**
- BasicInfoタブが参照モードで表示されている

**操作手順:**
1. BasicInfoタブを表示する

**期待結果:**
- `Key('basicInfoRead_container_section')` を持つウィジェットが存在する

**実装ノート（ウィジェットキー）:**
- `Key('basicInfoRead_container_section')`

---

#### TC-BTE-003: 参照モード時に「タップして編集」テキストが表示されること

**前提:**
- BasicInfoタブが参照モードで表示されている

**操作手順:**
1. BasicInfoタブを表示する

**期待結果:**
- 「タップして編集」テキストが表示されている

**実装ノート（ウィジェットキー）:**
- `Key('basicInfoRead_text_tapHint')`

---

#### TC-BTE-004: 参照モードのセクションをタップすると編集モードに切り替わること

**前提:**
- BasicInfoタブが参照モードで表示されている

**操作手順:**
1. BasicInfoタブを表示する
2. `Key('basicInfoRead_container_section')` をタップする

**期待結果:**
- 参照モードのビュー（`Key('basicInfoRead_container_section')`）が非表示になる
- 「タップして編集」テキスト（`Key('basicInfoRead_text_tapHint')`）が非表示になる
- キャンセルボタン（`Key('basicInfoForm_button_cancel')`）が表示される
- 保存ボタン（`Key('basicInfoForm_button_save')`）が表示される

**実装ノート（ウィジェットキー）:**
- `Key('basicInfoRead_container_section')`
- `Key('basicInfoRead_text_tapHint')`
- `Key('basicInfoForm_button_cancel')`
- `Key('basicInfoForm_button_save')`

---

#### TC-BTE-005: 編集モード時にフォーム下部にキャンセル・保存ボタンが表示されること

**前提:**
- BasicInfoタブが編集モードで表示されている（TC-BTE-004のタップ後）

**操作手順:**
1. TC-BTE-004の操作を実施し、編集モードに切り替える
2. フォーム下部にスクロールする

**期待結果:**
- `Key('basicInfoForm_button_cancel')` のキャンセルボタンが表示されている
- `Key('basicInfoForm_button_save')` の保存ボタンが表示されている
- 2つのボタンが横並びで表示されている

**実装ノート（ウィジェットキー）:**
- `Key('basicInfoForm_button_cancel')`
- `Key('basicInfoForm_button_save')`

---

#### TC-BTE-006: キャンセルボタンをタップすると参照モードに戻ること

**前提:**
- BasicInfoタブが編集モードで表示されている

**操作手順:**
1. TC-BTE-004の操作を実施し、編集モードに切り替える
2. イベント名フィールドを任意の文字列に変更する
3. `Key('basicInfoForm_button_cancel')` をタップする

**期待結果:**
- 参照モードのビュー（`Key('basicInfoRead_container_section')`）が表示される
- 「タップして編集」テキスト（`Key('basicInfoRead_text_tapHint')`）が表示される
- 変更したイベント名が元の値に戻っている（変更が破棄されている）

**実装ノート（ウィジェットキー）:**
- `Key('basicInfoRead_container_section')`
- `Key('basicInfoRead_text_tapHint')`
- `Key('basicInfoForm_button_cancel')`

---

#### TC-BTE-007: 保存ボタンをタップすると保存されて参照モードに戻ること

**前提:**
- BasicInfoタブが編集モードで表示されている

**操作手順:**
1. TC-BTE-004の操作を実施し、編集モードに切り替える
2. イベント名フィールドに「テスト保存イベント」と入力する
3. `Key('basicInfoForm_button_save')` をタップする
4. 保存処理が完了するまで待機する（最大5秒）

**期待結果:**
- 参照モードのビュー（`Key('basicInfoRead_container_section')`）が表示される
- 「タップして編集」テキスト（`Key('basicInfoRead_text_tapHint')`）が表示される
- 参照モードに「テスト保存イベント」が表示されている

**実装ノート（ウィジェットキー）:**
- `Key('basicInfoRead_container_section')`
- `Key('basicInfoRead_text_tapHint')`
- `Key('basicInfoForm_button_save')`

---

## ウィジェットキー一覧（全体まとめ）

| キー | 画面/状態 | 対象ウィジェット |
|---|---|---|
| `Key('basicInfoRead_container_section')` | 参照モード | GestureDetector（セクション全体） |
| `Key('basicInfoRead_text_tapHint')` | 参照モード | 「タップして編集」テキスト |
| `Key('basicInfoForm_button_cancel')` | 編集モード | キャンセルボタン |
| `Key('basicInfoForm_button_save')` | 編集モード | 保存ボタン |

---

## End of Spec
