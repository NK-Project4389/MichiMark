# TEST-FIX-2: Integration Test 残存FAIL修正 進捗

## 完了した作業

### 1. TEST-FIX-1: シードデータ切り替えバグ修正（完了）
- **原因**: `Platform.environment.containsKey('FLUTTER_TEST')` がiOSシミュレーターで動作しない（ホストのenv varはデバイスプロセスに渡らない）
- **修正**: `String.fromEnvironment('FLAVOR', defaultValue: 'dev')` (dart-define) に変更
- **結果**: シードデータ起因の全FAILが解消（38PASS/3SKIP/0FAIL）

### 2. ルール整備
- `orchestrator.md`: エージェントモデル配分テーブル追加（tester=Haiku を明記）
- `integration-test.md`: テストスコープ制限を冒頭に移動・pumpAndSettle禁止例の誤記修正

### 3. fuel_detail_design_test: 花子→田中メンバー名修正（完了）
- **修正**: `fuel_detail_design_test.dart` 内の「花子」→「田中」（B-17メンバー名変更対応）
- **結果**: 8PASS/0FAIL ✅

### 4. fab_and_unsaved_dialog_test: ListViewスクロールループ追加（完了）
- **原因**: `goToEventDetailNoTopic` で「近所のドライブ」がListViewの画面外にあり `find.text()` が空になっていた
- **修正**: `fab_and_unsaved_dialog_test.dart` にスクロールループを追加（テストコードのみ修正）
- **reviewer**: 承認（設計憲章・pumpAndSettle不使用・統合テストパターン適合）
- **結果**: 8PASS/0FAIL ✅（T-499 DONE）

### 5. dashboard_graph_popup_test: _pendingTapIndex方式修正（一部）
- **原因**: fl_chartの `FlTapUpEvent` 時に `response?.spot` が null になる（TapDown時のみsport情報あり）
- **修正**: `moving_cost_dashboard_view.dart` に `_pendingTapIndex` フィールドを追加してTapDown→TapUpを橋渡し
- **reviewer**: 承認（ローカルUIステートとして適切・レイヤー違反なし）
- **再テスト結果**: 1PASS/4FAIL → 問題が残存。要再調査

## 未完了

### T-498: dashboard_graph_popup 4FAIL残存
- **状況**: `_pendingTapIndex` 方式でreviewerは承認したがテストは4FAIL
- **失敗内容**: `Key('movingCost_tooltip_tap')` が依然0 widgetsで見つからない
- **次のアプローチ**: テストコード側のタップ方法（tapAt座標・GestureDetector探索方法）の見直しも検討

## 次回セッションで最初にやること

1. **T-498 再調査**: dashboard_graph_popup の4FAIL原因を深掘り
   - タップ座標・GestureDetector検索方法の見直し
   - BarChartタッチのテスト方法（`tester.tapAt` vs `tester.longPressAt`）
2. **T-500**: dashboard_graph_popup修正後にテスト実行（fab_and_unsaved_dialog分は完了済み）
3. **B-20 visitWork ActionTimeLogs**: `_testSeedEvents` へ追加（スルーテスト防止）
4. **全件テスト（3シャード）**: dashboard_graph_popup解消後に本番リリース前フルスイート実施
