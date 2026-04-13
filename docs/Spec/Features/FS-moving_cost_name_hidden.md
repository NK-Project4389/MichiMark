# Feature Spec: FS-moving_cost_name_hidden

- **Spec ID**: FS-moving_cost_name_hidden
- **対応要件**: REQ-moving_cost_name_hidden
- **作成日**: 2026-04-13
- **ステータス**: 確定
- **対象Feature**: mark_detail / link_detail
- **タスクID**: T-315（UI-10）

---

## 1. Purpose

トピック種別が「移動コスト系」（`movingCost` / `movingCostEstimated`）のイベントにおいて、MarkDetail および LinkDetail の「名称」入力フィールドを非表示にする。

移動コスト系トピックでは名称は意味を持たないため、フォームをシンプルにしてユーザーの入力負荷を下げる。

---

## 2. Scope

含むもの
- MarkDetail の名称フィールド（`markLinkName`）の表示制御
- LinkDetail の名称フィールド（`markLinkName`）の表示制御
- `TopicConfig` への `showNameField` フラグ追加

含まないもの
- データモデル（`MarkLinkDomain`）の変更
- 保存処理・Draft 構造の変更
- `MarkDetailArgs` / `LinkDetailArgs` の変更（`topicConfig` は既に両 Args に含まれているため追加不要）
- PaymentDetail（要件対象外）
- 他トピックへの影響

---

## 3. 「移動コスト」トピックの識別方法

### 3.1 TopicType enum

`flutter/lib/domain/topic/topic_domain.dart` で定義されている `TopicType` のうち、以下の2値が「移動コスト系」に該当する。

| enum 値 | 表示名 | 名称フィールド |
|---|---|---|
| `TopicType.movingCost` | 移動コスト（給油から計算） | **非表示** |
| `TopicType.movingCostEstimated` | 移動コスト（燃費で推定） | **非表示** |
| `TopicType.travelExpense` | 旅費可視化 | **表示** |

**設計根拠**: 要件書は「移動コストトピック」と記載しており、`movingCost` と `movingCostEstimated` はどちらも移動コスト可視化のユースケースであり、名称フィールドは両者とも不要である。

### 3.2 識別手段

Widget 層で直接 `TopicType` を参照することは設計憲章（§14）で禁止されている。`TopicConfig` にフラグ `showNameField` を追加し、View 層はこのフラグのみを参照して表示制御を行う。

---

## 4. TopicConfig への変更

`flutter/lib/domain/topic/topic_config.dart` の `TopicConfig` クラスに以下のフラグを追加する。

| フィールド名 | 型 | 説明 |
|---|---|---|
| `showNameField` | `bool` | MarkDetail / LinkDetail の名称フィールドを表示するか |

### 各 TopicType での設定値

| TopicType | `showNameField` |
|---|---|
| `movingCost` | `false` |
| `movingCostEstimated` | `false` |
| `travelExpense` | `true` |

---

## 5. MarkDetailArgs / LinkDetailArgs の変更有無

**変更不要。**

- `MarkDetailArgs` は既に `topicConfig` フィールドを持っている
- `LinkDetailArgs` は既に `topicConfig` フィールドを持っている
- Bloc 側（`MarkDetailLoaded` / `LinkDetailLoaded`）も `topicConfig` を State に保持している
- `showNameField` は `TopicConfig` の一部として自動的に引き継がれる

---

## 6. View 層での条件分岐実装方針

### 6.1 MarkDetail

`_MarkDetailForm.build()` 内で、`_NameField` ウィジェットの描画を `topicConfig.showNameField` で条件分岐する。

- `showNameField == true`: `_NameField` を表示する（現行通り）
- `showNameField == false`: `_NameField` および直後の `Divider` を描画しない

### 6.2 LinkDetail

`_LinkDetailForm.build()` 内で同様に `topicConfig.showNameField` で条件分岐する。

- `showNameField == true`: `_NameField` を表示する（現行通り）
- `showNameField == false`: `_NameField` および直後の `Divider` を描画しない

### 6.3 名称フィールドのキー

名称フィールドには以下のウィジェットキーを付与する。

| 画面 | キー |
|---|---|
| MarkDetail 名称フィールド | `Key('markDetail_field_name')` |
| LinkDetail 名称フィールド | `Key('linkDetail_field_name')` |

> **注記**: キーが存在しないと Integration Test で非表示確認が困難なため、非表示時はウィジェット自体をツリーから除外するが、テスト上は `findsNothing` で確認する。

---

## 7. Draft・保存処理への影響

- 名称フィールドが非表示の場合、ユーザーは名称を入力できないため Draft の `markLinkName` は初期値のまま保存される
- 既存データに名称が保存されている場合も、Draft 初期化時に既存値をそのまま保持する（空文字で上書きしない）
- 非表示時の Draft 変更は発生しないため、Bloc / Draft / Adapter に変更は不要

---

## 8. Data Flow

- 親（MichiInfo）からの `topicConfig` が `MarkDetailArgs` / `LinkDetailArgs` 経由で MarkDetailBloc / LinkDetailBloc に渡される
- Bloc は `topicConfig` を `MarkDetailLoaded` / `LinkDetailLoaded` State に保持する
- View（`_MarkDetailForm` / `_LinkDetailForm`）は `topicConfig.showNameField` を参照して名称フィールドの描画を決定する
- Widget 層で `TopicType` を直接参照することは禁止

---

## 9. Test Scenarios

### 前提条件

- iOSシミュレーター起動済み
- 「移動コスト（給油から計算）」トピックのイベントが DB に存在すること
- 「旅費可視化」トピックのイベントが DB に存在すること

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-MCN-001 | movingCost トピックで MarkDetail を開くと名称フィールドが非表示 | High |
| TC-MCN-002 | movingCost トピックで LinkDetail を開くと名称フィールドが非表示 | High |
| TC-MCN-003 | travelExpense トピックで MarkDetail を開くと名称フィールドが表示 | High |

---

### TC-MCN-001: movingCost トピックで MarkDetail を開くと名称フィールドが非表示

**前提:**
- DB に `TopicType.movingCost` のイベントが存在する
- そのイベントに Mark が1件以上存在する

**操作手順:**
1. イベント一覧からイベントをタップしてイベント詳細を開く
2. MichiInfo タブを表示する
3. Mark カードをタップして MarkDetail を開く

**期待結果:**
- MarkDetail 画面が表示される
- `Key('markDetail_field_name')` のウィジェットが画面上に存在しない（`findsNothing`）

**実装ノート（ウィジェットキー一覧）:**

| キー | 説明 |
|---|---|
| `Key('markDetail_field_name')` | 名称入力フィールド（非表示時は `findsNothing`） |
| `Key('markDetail_button_cancel')` | キャンセルボタン（画面到達確認用） |
| `Key('markDetail_button_save')` | 保存ボタン（画面到達確認用） |

---

### TC-MCN-002: movingCost トピックで LinkDetail を開くと名称フィールドが非表示

**前提:**
- DB に `TopicType.movingCost` のイベントが存在する
- そのイベントに Link が1件以上存在する

**操作手順:**
1. イベント一覧からイベントをタップしてイベント詳細を開く
2. MichiInfo タブを表示する
3. Link カードをタップして LinkDetail を開く

**期待結果:**
- LinkDetail 画面が表示される
- `Key('linkDetail_field_name')` のウィジェットが画面上に存在しない（`findsNothing`）

**実装ノート（ウィジェットキー一覧）:**

| キー | 説明 |
|---|---|
| `Key('linkDetail_field_name')` | 名称入力フィールド（非表示時は `findsNothing`） |
| `Key('linkDetail_button_cancel')` | キャンセルボタン（画面到達確認用） |
| `Key('linkDetail_button_save')` | 保存ボタン（画面到達確認用） |

---

### TC-MCN-003: travelExpense トピックで MarkDetail を開くと名称フィールドが表示

**前提:**
- DB に `TopicType.travelExpense` のイベントが存在する
- そのイベントに Mark が1件以上存在する

**操作手順:**
1. イベント一覧からイベントをタップしてイベント詳細を開く
2. MichiInfo タブを表示する
3. Mark カードをタップして MarkDetail を開く

**期待結果:**
- MarkDetail 画面が表示される
- `Key('markDetail_field_name')` のウィジェットが画面上に存在する（`findsOneWidget`）

**実装ノート（ウィジェットキー一覧）:**

| キー | 説明 |
|---|---|
| `Key('markDetail_field_name')` | 名称入力フィールド（表示時は `findsOneWidget`） |
| `Key('markDetail_button_cancel')` | キャンセルボタン（画面到達確認用） |
| `Key('markDetail_button_save')` | 保存ボタン（画面到達確認用） |

---

## 10. 変更ファイル一覧

| ファイル | 変更内容 |
|---|---|
| `flutter/lib/domain/topic/topic_config.dart` | `showNameField` フラグ追加・各 TopicType の設定値定義 |
| `flutter/lib/features/mark_detail/view/mark_detail_page.dart` | `_NameField` 描画を `topicConfig.showNameField` で条件分岐。`_NameField` に `Key('markDetail_field_name')` を付与 |
| `flutter/lib/features/link_detail/view/link_detail_page.dart` | `_NameField` 描画を `topicConfig.showNameField` で条件分岐。`_NameField` に `Key('linkDetail_field_name')` を付与 |

---

## End of Spec
