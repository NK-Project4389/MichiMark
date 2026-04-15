# 2026-04-15 F-2 ダッシュボード Spec作成（T-391 DONE）

## 完了した作業

### T-391: F-2 ダッシュボード Spec作成
- `docs/Spec/Features/FS-dashboard.md` 作成
- `docs/Requirements/REQ-dashboard.md` 更新（旅費よく使うルートTop3: 仮実装・非表示追加）

### 主な設計決定事項
- **ファイル構成**: `features/dashboard/` 配下に Bloc / Projection / Adapter / View を分離
- **DateRange クラス**: `DateRange.last7Days()` factory で無料版期間を生成。有料版拡張に対応
- **旅費 TopRoutes**: Projection/Adapter には実装、Widgetは `if (false)` ブロックで非表示
- **グラフライブラリ**: `fl_chart`（コンボ・ドーナツ）+ `table_calendar`（カレンダー）
- **Navigation**: `DashboardTravelEventTapped` Delegate → Root が EventDetail へ遷移
- **テストシナリオ**: TC-DB-001〜008（8件）定義

---

## 未完了

- T-392a: 実装（flutter-dev）
- T-392b: テストコード実装（tester）
- T-393: レビュー
- T-394: Integration Test 実行

---

## 次回セッションで最初にやること

1. T-403c: リモート実行結果確認（4/17 2:10 JSTにリモート自動実行予定）
2. T-392a/b: F-2 ダッシュボード 実装・テストコード実装（並行）
