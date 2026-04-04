# Aggregation 要件書

## 背景・目的

ActionTimeのログ（ActionTimeLog）が蓄積されることで、「移動時間」「作業時間」「休憩時間」などの状態ごとの所要時間を算出できるようになる。

Aggregationはこれらの時間データと既存の走行距離・費用データを組み合わせて、
**イベント単位・期間単位・タグ別** などの軸で集計・表示する機能である。

---

## ユーザーストーリー

- ユーザーとして、1回のドライブで移動・作業・休憩にそれぞれどれくらい時間を使ったか確認したい
- ユーザーとして、今月の作業時間・移動時間の合計を確認したい
- ユーザーとして、特定のタグやメンバーでフィルタして集計結果を確認したい
- ユーザーとして、期間を自由に指定して集計結果を確認したい

---

## 集計軸の定義

### 1. イベント単位集計

1回のEventに対する集計。EventDetailのOverviewに表示する。

| 集計項目 | 算出方法 | 依存データ |
|---|---|---|
| 移動時間 | moving状態の所要時間合計 | ActionTimeLog |
| 作業時間 | working状態の所要時間合計（休憩時間を除く） | ActionTimeLog |
| 休憩時間 | break_状態の所要時間合計 | ActionTimeLog |
| 滞留時間 | waiting状態の所要時間合計 | ActionTimeLog |
| 総走行距離 | 全Linkの走行距離合計 | MarkLinkDomain |
| 給油量合計 | 全MarkLinkのgasQuantity合計 | MarkLinkDomain |
| ガソリン代合計 | 全MarkLinkのgasPrice合計 | MarkLinkDomain |
| 経費合計 | 全PaymentのpaymentPrice合計 | PaymentDomain |

### 2. 期間単位集計

指定した期間（月次・任意期間）にわたる複数Eventの集計。

| 集計項目 | 算出方法 |
|---|---|
| 移動時間合計 | 対象Event全体のmoving時間合計 |
| 作業時間合計 | 対象Event全体のworking時間合計 |
| 休憩時間合計 | 対象Event全体のbreak_時間合計 |
| 総走行距離 | 対象Event全体の走行距離合計 |
| ガソリン代合計 | 対象Event全体のガソリン代合計 |
| 経費合計 | 対象Event全体の経費合計 |
| イベント件数 | 対象期間のイベント件数 |

**期間指定オプション：**
- 今月
- 先月
- 任意の開始日〜終了日

### 3. タグ別集計

指定したTagでフィルタした集計。期間単位集計と組み合わせ可能。

| フィルタ項目 | 内容 |
|---|---|
| Tag | EventDomain.tagsでフィルタ |
| Member | EventDomain.membersでフィルタ |
| Trans | EventDomain.transでフィルタ |
| Topic | EventDomain.topicでフィルタ |

---

## 状態所要時間の算出ロジック

ActionTimeLogを時系列ソートし、連続するログ間の差分から各状態の所要時間を算出する。

```
例：
09:00 出発（waiting → moving）
10:30 到着（moving → working）
11:00 休憩開始（working → break_）
11:15 休憩終了（break_ → working）
13:00 出発（working → moving）
14:00 帰着（moving → waiting）

算出結果：
  移動時間   = (10:30 - 09:00) + (14:00 - 13:00) = 1h30m + 1h00m = 2h30m
  作業時間   = (11:00 - 10:30) + (13:00 - 11:15) = 0h30m + 1h45m = 2h15m
  休憩時間   = (11:15 - 11:00) = 0h15m
  滞留時間   = ログが存在しないため算出不可（算出範囲外）
```

**ルール：**
- 最初のログより前の時間は算出対象外
- 最後のログ以降（イベント終了まで）の時間は算出対象外
- ログが1件のみの場合、所要時間は算出不可（`null`）
- 同一timestampのログが連続する場合は0分として扱う

---

## 機能要件

### AggregationResult（値オブジェクト）

集計結果を表すDomainオブジェクト。永続化しない（都度算出）。

```dart
class AggregationResult {
  final Duration? movingTime;
  final Duration? workingTime;
  final Duration? breakTime;
  final Duration? waitingTime;
  final int totalDistance;      // km
  final int? totalGasQuantity;  // 0.1L単位（10倍値）
  final int? totalGasPrice;     // 円
  final int? totalPayment;      // 円
  final int eventCount;
}
```

### 集計実行タイミング

- イベント単位集計：EventDetailのOverview表示時に算出
- 期間・タグ別集計：集計画面を開いたタイミングで算出

---

## UI要件

### イベントOverview

EventDetailのOverviewタブに集計結果を表示する。
表示項目はTopicによって切り替える（Topic要件書参照）。

### 集計画面（AggregationPage）

- 新規画面として追加
- 集計軸の選択：期間 / タグ / メンバー / Trans / Topic
- 期間指定：プリセット（今月・先月）または任意期間
- 集計結果の一覧表示

---

## 非機能要件

- 集計ロジックはAggregationService（またはUseCase）として独立して実装する
- AggregationResultはDomainオブジェクトとして定義し、UIに直接依存しない
- 大量データでも許容範囲内のパフォーマンスを維持する（目安：100件以下のEventに対してUI表示まで1秒以内）
- ActionTimeLogが存在しないEventでは、時間系の集計項目を`null`として表示する（"---"表示）

---

## 依存関係

| 依存先 | 内容 |
|---|---|
| ActionTime要件書 | ActionTimeLog・ActionStateの定義に依存 |
| Topic要件書 | OverviewのTopic別表示切り替えに依存 |
| EventDomain | tags・members・transのフィルタに依存 |

---

## スコープ外

- CSVエクスポート（別途要件書で定義）
- グラフ・チャート表示
- 他ユーザーとの比較
- リアルタイム集計（push通知など）

---

## 受け入れ条件

- [ ] EventDetailのOverviewにActionTimeLogから算出した移動・作業・休憩時間が表示される
- [ ] ActionTimeLogが存在しないEventのOverviewは時間項目が"---"と表示される
- [ ] 集計画面で今月・先月・任意期間を指定して集計結果を確認できる
- [ ] タグ・メンバー・Transでフィルタして集計できる
- [ ] 複数フィルタを組み合わせて集計できる（例：今月 × 特定タグ）
- [ ] 算出ロジックが要件の計算例と一致する
