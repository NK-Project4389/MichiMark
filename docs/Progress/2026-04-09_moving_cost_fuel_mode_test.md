# 進捗: 2026-04-09 MovingCostFuelMode Integration Test

**日付**: 2026-04-09

---

## 完了した作業

### T-115: MovingCostFuelMode Integration Test 実装・全件PASS

- テストファイル: `flutter/integration_test/fuel_detail_design_test.dart`
- 既存の fuel_detail_design_test.dart（TC-FD-001〜004）を上書きして TC-FCM-001〜008 を実装
- 全8件 PASS

| シナリオID | シナリオ名 | 結果 |
|---|---|---|
| TC-FCM-001 | movingCostEstimated イベントでMarkDetailの給油セクションが非表示であること | PASS |
| TC-FCM-002 | movingCost イベントでMarkDetailの給油セクションが表示されること | PASS |
| TC-FCM-003 | movingCost イベントのMarkDetailでガソリン支払者を選択・保存できること | PASS |
| TC-FCM-004 | movingCost イベントのLinkDetailでガソリン支払者を選択・保存できること | PASS |
| TC-FCM-005 | movingCost イベントのMarkDetailで isFuel=false のとき給油セクションが非表示であること | PASS |
| TC-FCM-006 | movingCostEstimated イベントの概要タブで燃費・ガソリン単価・ガソリン支払者が表示されること | PASS |
| TC-FCM-007 | movingCost イベントの概要タブで燃費・ガソリン単価・ガソリン支払者が非表示であること | PASS |
| TC-FCM-008 | 新規イベント作成時のTopic選択肢に movingCostEstimated が含まれること | PASS |

#### テスト実装上の工夫

- 「確定」ボタン（Selection画面 AppBar）は画面外に描画されるため `warnIfMissed: false` でタップ
- TC-FCM-008 の Topic名は EventList カードとBottomSheet両方で表示されるため `findsWidgets` を使用
- `CustomScrollView` を使ったスクロール検索で Mark/Link カードを特定

---

## 未完了 / 要対応

- 既存テスト失敗（前セッション持ち越し）: TC-MAD-006/007、TS-03/04（UI変更に伴う更新）

---

## 次回セッションで最初にやること

1. `docs/Tasks/TASKBOARD.md` を確認してタスクを確認する
2. 既存テスト失敗を修正する（TC-MAD-006/007、TS-03/04）
