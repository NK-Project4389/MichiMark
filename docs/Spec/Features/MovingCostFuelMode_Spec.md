# MovingCostFuelMode Feature Specification

Platform: **Flutter / Dart**
Version: 1.0
Purpose: movingCostを「給油実績モード」と「燃費推定モード」の2つのTopicTypeに分離し、ガソリン支払者をMarkDetail/LinkDetail単位で記録できるようにする。

## 改版履歴

| バージョン | 日付 | 変更概要 |
|---|---|---|
| 1.0 | 2026-04-09 | 初版作成（REQ-moving_cost_fuel_mode対応） |

---

# 1. Feature Overview

## Feature Name

MovingCostFuelMode

## Purpose

現在の `movingCost` トピックは、概要タブ（BasicInfoSection）に燃費・ガソリン単価・ガソリン支払者の入力欄を持ちながら、MarkDetail/LinkDetailにも給油セクションが存在する。これによりユーザーが「どこに入力すべきか」を判断できず混乱が生じている。

`TopicType` レベルで以下の2モードに分離することで入力場所を明確化する。

- `movingCost`（給油実績モード）: 給油記録（FuelDetail）を実績値として使用。概要タブの燃費・ガソリン単価・ガソリン支払者を非表示にし、MarkDetail/LinkDetailの給油セクションにガソリン支払者を追加する。
- `movingCostEstimated`（燃費推定モード）: 燃費（km/L）とガソリン単価から走行コストを推計する。概要タブに燃費・ガソリン単価・ガソリン支払者を表示し、MarkDetail/LinkDetailの給油セクションは非表示にする。

## Scope

含むもの
- `TopicType` enum への `movingCostEstimated` 追加
- `TopicConfig` の `movingCost` フラグ変更 + `movingCostEstimated` 定義追加
- `MarkLinkDomain` への `gasPayer: MemberDomain?` フィールド追加
- `mark_links` テーブルへの `gas_payer_id TEXT NULLABLE` カラム追加（schemaVersion 4）
- MarkDetail Feature: ガソリン支払者のDraft/Event/State/Delegate/Bloc変更
- LinkDetail Feature: ガソリン支払者のDraft/Event/State/Delegate/Bloc変更（MarkDetailと同仕様）
- `SelectionType` への `gasPayMember` ユースケース使用（既存定義済みのため実装のみ）
- イベント新規作成フローのTopicType選択肢に `movingCostEstimated` 追加
- シードデータへの `movingCostEstimated` トピックサンプルイベント追加

含まないもの
- 概要タブへの走行コスト割り勘表示（別フェーズ: T-112〜）
- 燃費更新機能（別フェーズ: T-120〜）
- travelExpense トピックへの影響
- カスタムTopic作成・編集（Phase 3）

---

# 2. Domain変更

## 2.1 TopicType enum 変更

### 追加するケース

| ケース名 | 説明 |
|---|---|
| `movingCostEstimated` | 燃費（km/L）とガソリン単価から走行コストを推計するモード |

### 変更後の全ケース

| ケース名 | 説明 |
|---|---|
| `movingCost` | 給油記録（FuelDetail）を実績として使用するモード（給油実績モード） |
| `movingCostEstimated` | 燃費（km/L）とガソリン単価から走行コストを推計するモード（燃費推定モード） |
| `travelExpense` | 経費・精算の記録が主目的 |

> `TopicType` を `switch` する箇所はすべてコンパイルエラーが発生する。`default` でのフォールスルーは禁止（設計憲章 14.6）。実装時は `movingCostEstimated` ケースを明示的に追加すること。

## 2.2 TopicConfig 変更

### movingCost（既存・変更あり）

| フラグ | 変更前 | 変更後 |
|---|---|---|
| `showKmPerGas` | `true` | `false` |
| `showPricePerGas` | `true` | `false` |
| `showPayMember` | `true` | `false` |
| `displayName` | `'移動コスト可視化'` | `'移動コスト（給油から計算）'` |
| その他フラグ | 変更なし | 変更なし |

### movingCostEstimated（新規追加）

| フラグ | 値 |
|---|---|
| `showMeterValue` | `true` |
| `showFuelDetail` | `false` |
| `addMenuItems` | `[mark, link]` |
| `showLinkDistance` | `true` |
| `showKmPerGas` | `true` |
| `showPricePerGas` | `true` |
| `showPayMember` | `true` |
| `showPaymentInfoTab` | `true` |
| `showActionTimeButton` | `false` |
| `themeColor` | `TopicThemeColor.emeraldGreen` |
| `displayName` | `'移動コスト（燃費で推定）'` |

> `TopicConfig.fromTopicType` の `switch` に `movingCostEstimated` ケースを追加する。フォールバック先（`type ?? TopicType.movingCost`）は変更しない。

## 2.3 MarkLinkDomain 変更

### 追加するフィールド

| フィールド名 | 型 | NULL許容 | デフォルト値 | 説明 |
|---|---|---|---|---|
| `gasPayer` | `MemberDomain?` | ✅ | `null` | 給油費用の支払者。`isFuel == true` のとき意味を持つ |

- 既存フィールドに変更なし
- `copyWith` に `gasPayer` パラメータを追加する
- `props` に `gasPayer` を追加する
- UIを知らない・Draftを知らない

---

# 3. DBスキーマ変更

## 3.1 mark_links テーブル変更

### 追加するカラム

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| `gas_payer_id` | TEXT | NULLABLE, FK → members(id) | ガソリン支払者ID |

- 既存レコードに対してデフォルト値 `NULL` が適用される
- 外部キー制約: `members(id)` の参照。DeleteRule は `setNull`（メンバーが削除されても MarkLink は残す）

### drift テーブル定義への追加

`MarkLinks` クラスに以下を追加する。

| drift カラム定義 | 型 | 説明 |
|---|---|---|
| `gasPayerId` | `TextColumn` (nullable, references Members) | ガソリン支払者ID |

## 3.2 マイグレーション

| 項目 | 値 |
|---|---|
| 現在の schemaVersion | 3 |
| 変更後の schemaVersion | **4** |
| マイグレーション SQL | `ALTER TABLE mark_links ADD COLUMN gas_payer_id TEXT REFERENCES members(id)` |

マイグレーション対象: `from < 4` のとき上記 SQL を実行する。

---

# 4. MarkDetail Feature 変更

## 4.1 MarkDetailDraft 変更

### 追加するフィールド

| フィールド名 | 型 | NULL許容 | デフォルト値 | 説明 |
|---|---|---|---|---|
| `selectedGasPayer` | `MemberDomain?` | ✅ | `null` | 選択中のガソリン支払者 |

## 4.2 BlocEvent 変更

### 追加するEvent

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `MarkDetailEditGasPayerPressed` | ガソリン支払者の選択ボタンがタップされたとき | ガソリン支払者選択画面へ遷移する意図をBlocに通知する |
| `MarkDetailGasPayerSelected` | 選択画面からガソリン支払者が返却されたとき | `members: List<MemberDomain>` から最初の1件を `selectedGasPayer` に設定する |

### 変更しないEvent

既存のEventはすべて変更なし。

## 4.3 BlocState 変更

`MarkDetailLoaded` に変更なし（ガソリン支払者は Draft に保持するため State への直接追加は不要）。

> `availableMembers` はガソリン支払者の選択画面でも同じイベントメンバーリストを使用する。

## 4.4 Delegate変更

### 追加するDelegate

| Delegate名 | 遷移先・説明 |
|---|---|
| `MarkDetailOpenGasPayerSelectionDelegate` | SelectionType.gasPayMember の選択画面を開く（単一選択モード） |

### 変更しないDelegate

既存のDelegateはすべて変更なし。

## 4.5 Bloc ロジック変更

### MarkDetailStarted 変更

既存 MarkLink を読み込む際、`markLink.gasPayer` を `draft.selectedGasPayer` に設定する。

### MarkDetailSaveTapped 変更

保存時に `MarkLinkDomain` を生成する際、`draft.selectedGasPayer` を `gasPayer` フィールドに設定する。

## 4.6 UI 表示条件

給油セクション（`isFuel == true` のとき表示される領域）内に「ガソリン支払者」の選択行を追加する。

| 条件 | 表示 |
|---|---|
| `topicConfig.showFuelDetail == true` かつ `draft.isFuel == true` | ガソリン支払者選択行を表示する |
| 上記以外 | 非表示 |

表示内容:
- ラベル: `ガソリン支払者`
- 値: `selectedGasPayer?.name` または空欄（未選択時）
- タップ: `MarkDetailEditGasPayerPressed` を発火する

---

# 5. LinkDetail Feature 変更

MarkDetail と同仕様。以下にLinDetail固有の名称を示す。

## 5.1 LinkDetailDraft 変更

### 追加するフィールド

| フィールド名 | 型 | NULL許容 | デフォルト値 | 説明 |
|---|---|---|---|---|
| `selectedGasPayer` | `MemberDomain?` | ✅ | `null` | 選択中のガソリン支払者 |

## 5.2 BlocEvent 変更

### 追加するEvent

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `LinkDetailEditGasPayerPressed` | ガソリン支払者の選択ボタンがタップされたとき | ガソリン支払者選択画面へ遷移する意図を通知する |
| `LinkDetailGasPayerSelected` | 選択画面からガソリン支払者が返却されたとき | `members: List<MemberDomain>` から最初の1件を `selectedGasPayer` に設定する |

## 5.3 Delegate変更

### 追加するDelegate

| Delegate名 | 遷移先・説明 |
|---|---|
| `LinkDetailOpenGasPayerSelectionDelegate` | SelectionType.gasPayMember の選択画面を開く（単一選択モード） |

## 5.4 Bloc ロジック変更

MarkDetailと同仕様。`LinkDetailStarted` の読み込み時・`LinkDetailSaveTapped` の保存時に `gasPayer` を処理する。

## 5.5 UI 表示条件

MarkDetailと同仕様。`topicConfig.showFuelDetail == true` かつ `draft.isFuel == true` のとき、給油セクション内にガソリン支払者選択行を表示する。

---

# 6. SelectionType

`SelectionType.gasPayMember` は設計憲章 §12 に既定義済みのため、追加定義は不要。

選択画面の呼び出し仕様:

| 項目 | 値 |
|---|---|
| `SelectionType` | `gasPayMember` |
| `SelectionMode` | `single`（単一選択） |
| 候補リスト | `availableMembers`（イベントメンバー一覧） |
| 返却値 | `List<MemberDomain>`（1件のみ） |

---

# 7. イベント新規作成フローへの影響

- `EventCreateWithTopic` フロー（T-021等）の Topic 選択肢に `movingCostEstimated` を追加する
- イベント一覧・EventDetail のトピック表示名は `TopicConfig.fromTopicType(topicType).displayName` をそのまま使用するため、追加の実装は不要
- 新規作成フローで選択可能な TopicType: `movingCost`、`movingCostEstimated`、`travelExpense`

---

# 8. シードデータ

`movingCostEstimated` トピック種別のサンプルイベントを1件追加する。

| 項目 | 値 |
|---|---|
| topicType | `movingCostEstimated` |
| topicName | `'移動コスト（燃費で推定）'` |
| color | `'emeraldGreen'` |

---

# 9. Data Flow

## ガソリン支払者の選択フロー（MarkDetail / LinkDetail 共通）

- ユーザーがガソリン支払者の選択行をタップする
- `EditGasPayerPressed` Event が発火する
- Bloc が `OpenGasPayerSelectionDelegate` を State に乗せる
- PageのBlocListenerがDelegateを受け取り、`context.push` で選択画面を開く（単一選択モード）
- ユーザーがメンバーを選択すると選択画面が `context.pop(result)` で結果を返す
- Page が結果を受け取り `GasPayerSelected` Event を発火する
- Bloc が Draft の `selectedGasPayer` を更新する
- Widget が `draft.selectedGasPayer?.name` を表示する

## 保存フロー（MarkDetail / LinkDetail 共通）

- ユーザーが保存ボタンをタップする
- `SaveTapped` Event が発火する
- Bloc が `draft.selectedGasPayer` を `MarkLinkDomain.gasPayer` に設定して Repository に保存する
- Repository（drift）が `gas_payer_id` を `mark_links` テーブルに書き込む

## 読み込みフロー（既存MarkLink編集時）

- `Started` Event 受信時に EventRepository から MarkLinkDomain を取得する
- `markLink.gasPayer` を `draft.selectedGasPayer` に設定してLoadedを emit する

---

# 10. 互換性・マイグレーション方針

## 既存データとの互換性

- `mark_links` テーブルへの `gas_payer_id` カラム追加はNULLABLEのため、既存レコードには `NULL` が適用される
- 既存の `movingCost` イベントは引き続き正常に動作する。フラグ変更（`showKmPerGas` 等を `false`）は UI 表示の変更のみであり、保存済みデータには影響しない
- `movingCostEstimated` は新規 TopicType のため、既存イベントには影響しない

## マイグレーション実装方針

- `database.dart` の `schemaVersion` を `3` から `4` に変更する
- `onUpgrade` に `if (from < 4)` ブロックを追加し、以下を実行する:
  - `ALTER TABLE mark_links ADD COLUMN gas_payer_id TEXT REFERENCES members(id)`
- `onCreate` は `m.createAll()` で新テーブル定義をそのまま適用するため変更不要

## drift テーブル定義との整合

- `MarkLinks` クラスに `gasPayerId` カラムを追加することで、`build_runner` による再生成が必要になる
- 生成ファイル（`database.g.dart`、`event_dao.g.dart`）は再生成する

## EventDao への影響

- MarkLink取得時: `gas_payer_id` から `MemberDomain` を解決して `MarkLinkDomain.gasPayer` に設定する
  - 解決方法: `members` テーブルを `gas_payer_id` でLOOKUP（NULLABLEのため存在しない場合は `null`）
- MarkLink保存時: `MarkLinkDomain.gasPayer?.id` を `gas_payer_id` に設定する（`null` は `NULL` として保存）

---

# 11. Test Scenarios

## 前提条件

- iOSシミュレーターが起動済みであること
- `movingCost` タイプのサンプルイベントが存在すること
- `movingCostEstimated` タイプのサンプルイベントが存在すること
- 各イベントにメンバーが2名以上登録されていること

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-FCM-001 | movingCostEstimated イベントでMarkDetailの給油セクションが非表示であること | High |
| TC-FCM-002 | movingCost イベントでMarkDetailの給油セクションが表示されること | High |
| TC-FCM-003 | movingCost イベントのMarkDetailでガソリン支払者を選択・保存できること | High |
| TC-FCM-004 | movingCost イベントのLinkDetailでガソリン支払者を選択・保存できること | High |
| TC-FCM-005 | movingCost イベントのMarkDetailで isFuel=false のとき給油セクション（ガソリン支払者含む）が非表示であること | Medium |
| TC-FCM-006 | movingCostEstimated イベントの概要タブで燃費・ガソリン単価・ガソリン支払者が表示されること | High |
| TC-FCM-007 | movingCost イベントの概要タブで燃費・ガソリン単価・ガソリン支払者が非表示であること | High |
| TC-FCM-008 | 新規イベント作成時のTopic選択肢に movingCostEstimated が含まれること | Medium |

## シナリオ詳細

### TC-FCM-001: movingCostEstimated イベントでMarkDetailの給油セクションが非表示であること

**操作手順:**
1. イベント一覧から `movingCostEstimated` タイプのイベントをタップする
2. MichiInfoタブを開く
3. Markをタップして MarkDetail を開く

**期待結果:**
- 給油フラグのスイッチが表示されない
- 給油量・ガソリン単価・合計金額の入力欄が表示されない
- ガソリン支払者の選択行が表示されない

---

### TC-FCM-002: movingCost イベントでMarkDetailの給油セクションが表示されること

**操作手順:**
1. イベント一覧から `movingCost` タイプのイベントをタップする
2. MichiInfoタブを開く
3. Markをタップして MarkDetail を開く

**期待結果:**
- 給油フラグのスイッチが表示される

---

### TC-FCM-003: movingCost イベントのMarkDetailでガソリン支払者を選択・保存できること

**操作手順:**
1. `movingCost` タイプのイベントの MarkDetail を開く
2. 給油フラグをONにする
3. ガソリン支払者の選択行をタップする
4. メンバー選択画面でいずれかのメンバーを選択して確定する
5. 保存ボタンをタップする
6. 同じ MarkDetail を再度開く

**期待結果:**
- 手順4で選択したメンバー名がガソリン支払者に表示される

---

### TC-FCM-004: movingCost イベントのLinkDetailでガソリン支払者を選択・保存できること

**操作手順:**
1. `movingCost` タイプのイベントの LinkDetail を開く
2. 給油フラグをONにする
3. ガソリン支払者の選択行をタップする
4. メンバー選択画面でいずれかのメンバーを選択して確定する
5. 保存ボタンをタップする
6. 同じ LinkDetail を再度開く

**期待結果:**
- 手順4で選択したメンバー名がガソリン支払者に表示される

---

### TC-FCM-005: movingCost イベントのMarkDetailで isFuel=false のとき給油セクションが非表示であること

**操作手順:**
1. `movingCost` タイプのイベントの MarkDetail を開く
2. 給油フラグがOFFであることを確認する（またはOFFにする）

**期待結果:**
- 給油量・ガソリン単価・合計金額の入力欄が表示されない
- ガソリン支払者の選択行が表示されない

---

### TC-FCM-006: movingCostEstimated イベントの概要タブで燃費・ガソリン単価・ガソリン支払者が表示されること

**操作手順:**
1. `movingCostEstimated` タイプのイベントをタップする
2. 概要タブ（BasicInfo）を開く

**期待結果:**
- 燃費フィールドが表示される
- ガソリン単価フィールドが表示される
- ガソリン支払者フィールドが表示される

---

### TC-FCM-007: movingCost イベントの概要タブで燃費・ガソリン単価・ガソリン支払者が非表示であること

**操作手順:**
1. `movingCost` タイプのイベントをタップする
2. 概要タブ（BasicInfo）を開く

**期待結果:**
- 燃費フィールドが表示されない
- ガソリン単価フィールドが表示されない
- ガソリン支払者フィールドが表示されない

---

### TC-FCM-008: 新規イベント作成時のTopic選択肢に movingCostEstimated が含まれること

**操作手順:**
1. イベント一覧画面で新規作成ボタンをタップする
2. Topic選択画面を表示する

**期待結果:**
- `'移動コスト（燃費で推定）'` が選択肢に表示される
- `'移動コスト（給油から計算）'` が選択肢に表示される

---

# 12. 影響ファイル一覧

| ファイルパス | 変更種別 | 内容 |
|---|---|---|
| `lib/domain/topic/topic_domain.dart` | 変更 | `TopicType.movingCostEstimated` 追加 |
| `lib/domain/topic/topic_config.dart` | 変更 | `movingCostEstimated` の `TopicConfig` 定義追加・`movingCost` のフラグ変更・`displayName` 変更 |
| `lib/domain/transaction/mark_link/mark_link_domain.dart` | 変更 | `gasPayer: MemberDomain?` フィールド追加 |
| `lib/repository/impl/drift/tables/event_tables.dart` | 変更 | `MarkLinks` クラスに `gasPayerId` カラム追加 |
| `lib/repository/impl/drift/database.dart` | 変更 | `schemaVersion` を 4 に変更・`onUpgrade` に `if (from < 4)` ブロック追加 |
| `lib/repository/impl/drift/dao/event_dao.dart` | 変更 | MarkLink取得時に `gas_payer_id` → `MemberDomain` を解決・保存時に `gasPayer?.id` を設定 |
| `lib/repository/impl/drift/dao/event_dao.g.dart` | 再生成 | `build_runner` による自動生成 |
| `lib/repository/impl/drift/database.g.dart` | 再生成 | `build_runner` による自動生成 |
| `lib/features/mark_detail/draft/mark_detail_draft.dart` | 変更 | `selectedGasPayer: MemberDomain?` フィールド追加 |
| `lib/features/mark_detail/bloc/mark_detail_event.dart` | 変更 | `MarkDetailEditGasPayerPressed`・`MarkDetailGasPayerSelected` 追加 |
| `lib/features/mark_detail/bloc/mark_detail_state.dart` | 変更 | `MarkDetailOpenGasPayerSelectionDelegate` 追加 |
| `lib/features/mark_detail/bloc/mark_detail_bloc.dart` | 変更 | gasPayer関連イベントハンドラ追加・Startedでの読み込み変更・SaveTappedでの保存変更 |
| `lib/features/mark_detail/view/mark_detail_page.dart` | 変更 | BlocListenerへの`MarkDetailOpenGasPayerSelectionDelegate`対応・給油セクションへのUI追加 |
| `lib/features/link_detail/draft/link_detail_draft.dart` | 変更 | `selectedGasPayer: MemberDomain?` フィールド追加 |
| `lib/features/link_detail/bloc/link_detail_event.dart` | 変更 | `LinkDetailEditGasPayerPressed`・`LinkDetailGasPayerSelected` 追加 |
| `lib/features/link_detail/bloc/link_detail_state.dart` | 変更 | `LinkDetailOpenGasPayerSelectionDelegate` 追加 |
| `lib/features/link_detail/bloc/link_detail_bloc.dart` | 変更 | gasPayer関連イベントハンドラ追加・Startedでの読み込み変更・SaveTappedでの保存変更 |
| `lib/features/link_detail/view/link_detail_page.dart` | 変更 | BlocListenerへの`LinkDetailOpenGasPayerSelectionDelegate`対応・給油セクションへのUI追加 |

---

# End of MovingCostFuelMode Spec
