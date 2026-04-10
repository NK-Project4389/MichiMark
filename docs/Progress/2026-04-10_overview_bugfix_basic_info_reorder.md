# 進捗: 2026-04-10 セッション（概要集計バグ修正・BasicInfo項目並び替え・タスクボード更新）

**日付**: 2026-04-10

---

## 完了した作業

### 1. movingCostEstimated 概要集計バグ修正（バグ修正）

**症状**: movingCostEstimated トピックのイベントで、概要タブの集計サマリにガソリン代（推計）が表示されなかった。支払情報は正常表示。

**原因**: `overview_bloc.dart` の分岐条件が `topicConfig.showFuelDetail` だった。
- `movingCost`: `showFuelDetail: true` → 正常に AggregationService パスへ
- `movingCostEstimated`: `showFuelDetail: false` → travelExpense パスに落ちていた

**修正内容**:
- `lib/features/overview/bloc/overview_bloc.dart`: discriminator を `showFuelDetail` → `showLinkDistance` に変更（movingCost・movingCostEstimated 両方が true、travelExpense が false）
- `lib/adapter/event_detail_overview_adapter.dart`: 実績ガソリン代が null の場合、`totalDistance / (kmPerGas/10) * pricePerGas` で推計ガソリン代を計算して表示

### 2. BasicInfo 項目並び替え（要望）

`basic_info_view.dart` の ReadView・Form 両方で以下の順序に変更:

| 変更前 | 変更後 |
|---|---|
| イベント名 | イベント名 |
| 交通手段 | 交通手段 |
| 燃費（条件付き） | **メンバー**（交通手段の直下に移動） |
| ガソリン単価（条件付き） | タグ |
| メンバー | 燃費（条件付き） |
| タグ | ガソリン単価（条件付き） |
| ガソリン支払者（条件付き） | **ガソリン支払者**（ガソリン単価の直下に移動） |

### 3. TC-BTF テスト修正

- TC-BTF-001/002 が `movingCost` トピックのイベントを使っていたが、MovingCostFuelMode 実装後 `showKmPerGas: false` になったため燃費フィールドが非表示になっていた
- `週末ドライブ（燃費推定）`（movingCostEstimated・showKmPerGas: true）に変更 → PASS

### 4. タスクボード更新

- Phase 14: イベント削除機能 + スワイプ削除UI タスク追加（T-130〜T-134）
  - `flutter_slidable ^3.1.0` 使用
  - カスケード削除（地点・経路・イベント本体）
  - 確認ダイアログなし・即削除
  - T-130（要件書）は DONE（ユーザー提示仕様をそのまま記録）

---

## テスト結果

| テスト | 結果 |
|---|---|
| TC-BTF-001 | PASS |
| TC-BTF-002 | PASS |
| TC-FCM-001〜008 | 全件 PASS（overview_bloc 修正の影響なし） |
| TC-EOD-001〜015 | PASS（3件SKIP） |
| その他既存テスト | PASS |

---

## 未完了 / 要対応

- michi_info ビルドエラー（T-101 IN_PROGRESS セッションの作業中、別セッションが対応中）
  - `_onInsertModeFabPressed` 等ハンドラ未実装
- 既存テスト失敗（前セッションから継続）
  - TC-MAD-006/007（mark_addition_defaults_test.dart）
  - TS-03/04（michi_info_layout_test.dart）
- T-131（イベント削除機能 Spec作成）→ TODO

---

## 次回セッションで最初にやること

1. `docs/Tasks/TASKBOARD.md` を確認
2. T-101（カード挿入機能実装）が完了していればT-102レビューへ
3. T-131（イベント削除機能 Spec作成）を進める
4. 既存テスト失敗（TC-MAD-006/007、TS-03/04）を修正する
