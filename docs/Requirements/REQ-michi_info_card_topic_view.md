# 要件書: MichiInfoカード トピック別表示切り替え

要件書ID: REQ-michi_info_card_topic_view
作成日: 2026-04-13
ステータス: 確定

---

## 概要・背景

現在のMichiInfo（ミチタブ）一覧に表示されるMark（地点）カード・Link（区間）カードは、トピック種別に関わらず共通の表示項目（名称・累積メーター・削除ボタン）しか持たない。

トピックによって「記録の主目的」が異なるため（movingCost = 燃料・距離管理、travelExpense = 経費・精算管理）、カードに表示する情報もトピックに応じて最適化したい。

本要件では、MichiInfoカード部品を刷新し、登録されたトピック種別に応じて表示内容が動的に切り替わる仕組みを導入する。

---

## トピック種別と表示内容の対応表

### Mark（地点）カード

| 表示項目 | movingCost | movingCostEstimated | travelExpense | 備考 |
|---|---|---|---|---|
| 名称 | 非表示 | 非表示 | 表示 | `showNameField` フラグと連動 |
| 日付 | 表示 | 表示 | 表示 | 全トピック共通 |
| 参加メンバー名（先頭最大2名 + 残数） | 非表示 | 非表示 | 表示 | travelExpenseのみ |
| 累積メーター値（例: "12,345 km"） | 表示 | 表示 | 非表示 | `showMeterValue` フラグと連動 |
| 給油サマリーアイコン（ドット上の⛽ジャンプ） | 表示 | 非表示 | 非表示 | `showFuelDetail` かつ `isFuel == true` のとき |
| 状態バッジ（ActionTime用） | 非表示 | 非表示 | 非表示 | `showActionTimeButton` フラグと連動（現在全トピックfalse） |
| ⚡ ActionTimeボタン | 非表示 | 非表示 | 非表示 | `showActionTimeButton` フラグと連動（現在全トピックfalse） |
| 削除ボタン | 表示 | 表示 | 表示 | 全トピック共通（挿入モード中は非表示） |

### Link（区間）カード

| 表示項目 | movingCost | movingCostEstimated | travelExpense | 備考 |
|---|---|---|---|---|
| 名称 | 非表示 | 非表示 | 表示 | `showNameField` フラグと連動 |
| 日付 | 表示 | 表示 | 非表示 | movingCost・movingCostEstimatedのみ |
| 区間距離（例: "120 km"） | 表示 | 表示 | 非表示 | `showLinkDistance` フラグと連動 |
| 削除ボタン | 表示 | 表示 | 表示 | 全トピック共通（挿入モード中は非表示） |

---

## 機能要件

### REQ-F-001: Mark（地点）カード 日付表示

全トピック共通で、Markカード内に日付を表示する。

- 表示形式: `displayDate`（既存フィールド）を使用する
- 表示位置: カード内の名称または累積メーターの下（トピックに応じて配置を最適化）
- movingCost / movingCostEstimated: 名称が非表示のため、日付を最上段に配置する
- travelExpense: 名称の下に日付を配置する

### REQ-F-002: Mark（地点）カード メンバー表示（travelExpenseのみ）

travelExpenseのMarkカードに参加メンバー名を表示する。

- 表示形式: 先頭2名を「A・B」形式で表示し、3名以上の場合は「A・B + X人」形式とする
- メンバーが1名の場合は「A」のみ表示する
- メンバーが0名の場合は非表示とする
- `MarkLinkItemProjection.members`（既存フィールド）を参照する

### REQ-F-003: Link（区間）カード 日付・距離表示（movingCost / movingCostEstimatedのみ）

movingCost / movingCostEstimatedのLinkカードに日付と区間距離を表示する。

- 日付: `displayDate` を使用する
- 区間距離: `displayDistanceValue` を使用する（null の場合は距離非表示）
- 表示位置: カード内に収まるよう簡潔に表示する

### REQ-F-004: 表示切り替えは `TopicConfig` フラグのみで制御する

カード内の表示ロジックはTopicTypeを直接switch/if比較せず、TopicConfigの既存フラグ（`showNameField`、`showMeterValue`、`showLinkDistance`、`showFuelDetail`）を参照して切り替える。

新たなフラグが必要な場合は `TopicConfig` に追加する。

### REQ-F-005: 新規フラグの追加

以下のフラグを `TopicConfig` に追加する。

| フラグ名 | 型 | 説明 | movingCost | movingCostEstimated | travelExpense |
|---|---|---|---|---|---|
| `showMarkDate` | `bool` | Markカードに日付を表示するか | `true` | `true` | `true` |
| `showMarkMembers` | `bool` | Markカードに参加メンバーを表示するか | `false` | `false` | `true` |
| `showLinkDate` | `bool` | Linkカードに日付を表示するか | `true` | `true` | `false` |

---

## 非機能要件

### REQ-NF-001: 表示項目追加によるカード高さ変化

表示項目が増えた場合でもタイムラインレイアウト（スパン矢印・縦線）と整合するよう、カード高さの変化に対応する。

- `_cardHeight`（72.0）はMarkカード本体の最小高さとし、表示項目が増えた場合は高さを拡張できる柔軟な設計とする
- タイムライン計算（`_buildTimelineData`）において、カード高さを動的に取得できるよう設計する（現状は定数で管理）
- ただし、**今回のフェーズでは固定高さは維持する**（カード高さを変えず表示内容を72dp内に収める）

### REQ-NF-002: 既存のカード高さ・レイアウトを変更しない

今回の変更でMarkカード高さ（72dp）・Linkカード高さ（34dp）は変更しない。

表示項目が増える場合は、カード内に収まるよう文字サイズ・省略を適切に調整する。

### REQ-NF-003: テストシナリオを実装可能なWidget Keyを付与する

新規追加する表示要素には適切なWidget Keyを付与する。

---

## スコープ外

- カード高さを動的に変更するレイアウト変更（将来フェーズ）
- メンバーアイコン（アバター画像）表示
- タップ時の詳細画面表示変更（既存のままとする）
- 給油情報の詳細数値（給油量・金額）のカード内表示
