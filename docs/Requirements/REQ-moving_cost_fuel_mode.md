# 要件書: 移動コスト 燃費モード分離

**要件書ID**: REQ-moving_cost_fuel_mode
**作成日**: 2026-04-09
**ステータス**: 確定

---

## 1. 背景・目的

現在の `movingCost` トピックは、概要タブ（BasicInfoSection）に燃費・ガソリン単価・ガソリン支払者の入力欄を持ちながら、同時にMarkDetail/LinkDetailにも給油セクションが存在する。ユーザーがガソリンコストを登録する際に「どこに入力すべきか」が判断できず、混乱が生じる。

これを解消するため、「給油記録（実績値）で計算するモード」と「燃費（推計値）で計算するモード」をTopicTypeレベルで分離する。

---

## 2. 新しいTopicType

### 追加: `movingCostEstimated`（移動コスト・燃費で推定）

燃費（km/L）とガソリン単価から走行コストを推計するモード。

| TopicConfigフラグ | 値 |
|---|---|
| `showMeterValue` | `true` |
| `showFuelDetail` | **`false`**（給油セクション非表示） |
| `addMenuItems` | `[mark, link]` |
| `showLinkDistance` | `true` |
| `showKmPerGas` | **`true`**（燃費を概要に表示） |
| `showPricePerGas` | **`true`**（ガソリン単価を概要に表示） |
| `showPayMember` | **`true`**（ガソリン支払者を概要に表示） |
| `showPaymentInfoTab` | `true` |
| `showActionTimeButton` | `false` |
| `themeColor` | `TopicThemeColor.emeraldGreen`（既存と同じ） |
| `displayName` | `"移動コスト（燃費で推定）"` |

### 変更: `movingCost`（移動コスト・給油から計算）

給油記録（FuelDetail）を実績として使用するモード。

| TopicConfigフラグ | 変更前 | 変更後 |
|---|---|---|
| `showKmPerGas` | `true` | **`false`**（概要の燃費を非表示） |
| `showPricePerGas` | `true` | **`false`**（概要のガソリン単価を非表示） |
| `showPayMember` | `true` | **`false`**（概要のガソリン支払者を非表示） |
| `displayName` | `"移動コスト可視化"` | **`"移動コスト（給油から計算）"`** |
| その他フラグ | 変更なし | 変更なし |

---

## 3. 各モードの入力場所の役割

### `movingCostEstimated`（燃費推定モード）

```
概要タブ（BasicInfoSection）
  交通手段: [選択] → 燃費を自動転記
  燃費: 15.5 km/L  ← 入力・編集可能
  ガソリン単価: 170 円/L  ← 入力
  ガソリン支払者: [選択]

MichiInfo
  MarkDetail: 給油セクション 非表示
  LinkDetail: 給油セクション 非表示
```

### `movingCost`（給油実績モード）

```
概要タブ（BasicInfoSection）
  燃費・ガソリン単価・ガソリン支払者: 非表示

MichiInfo
  MarkDetail: 給油セクション 表示
    - 給油スイッチ・給油量・ガソリン単価・合計金額
    - ★新規追加: ガソリン支払者（メンバー選択）
  LinkDetail: 給油セクション 表示
    - 給油スイッチ・給油量・ガソリン単価・合計金額
    - ★新規追加: ガソリン支払者（メンバー選択）
```

---

## 4. 新規追加項目: ガソリン支払者（MarkDetail / LinkDetail）

### 4-1. MarkDetail ガソリン支払者

- **表示条件**: `isFuel == true` のとき表示（給油セクション内）
- **操作**: タップ → メンバー選択画面（既存の SelectionFeature を使用）
- **表示名**: `ガソリン支払者`
- **未選択時**: 空欄表示（必須ではない）
- **Domain追加**: `MarkLinkDomain.gasPayer: MemberDomain?`
- **DB追加**: `mark_links` テーブルに `gas_payer_id TEXT` カラム追加

### 4-2. LinkDetail ガソリン支払者

MarkDetailと同仕様。

---

## 5. イベント新規作成フローへの影響

- `TopicType.movingCostEstimated` をトピック選択肢に追加する
- イベント一覧・EventDetailのトピック表示名は `displayName` をそのまま使用するため追加実装不要

---

## 6. 非スコープ

- 概要タブへの走行コスト割り勘表示（別フェーズ: T-112〜）
- 燃費更新機能（別フェーズ: T-120〜）
- travelExpenseトピックへの影響なし

---

## 7. 影響ファイル概要

| ファイル | 変更種別 | 内容 |
|---|---|---|
| `domain/topic/topic_domain.dart` | 変更 | `TopicType.movingCostEstimated` 追加 |
| `domain/topic/topic_config.dart` | 変更 | `movingCostEstimated` のTopicConfig定義追加、`movingCost` のフラグ変更・displayName変更 |
| `domain/transaction/mark_link/mark_link_domain.dart` | 変更 | `gasPayer: MemberDomain?` フィールド追加 |
| `repository/drift` | 変更 | `mark_links` テーブルに `gas_payer_id` カラム追加、マイグレーション対応 |
| `features/mark_detail/` | 変更 | 給油セクションにガソリン支払者UI追加 |
| `features/link_detail/` | 変更 | 給油セクションにガソリン支払者UI追加 |
| シードデータ | 変更 | `movingCostEstimated` トピックのサンプルイベント追加 |
