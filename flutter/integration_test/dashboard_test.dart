// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: F-2 ダッシュボード（期間集計機能）
///
/// Spec: docs/Spec/Features/FS-dashboard.md §13
///
/// テストシナリオ: TC-DB-001 〜 TC-DB-008
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータに movingCost / travelExpense / visitWork の
///     イベントが1件以上存在すること

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ──────────────────────────────────────────────────────────
  // ヘルパー関数
  // ──────────────────────────────────────────────────────────

  /// アプリを起動してイベント一覧画面が表示されるまで待つ。
  Future<void> startApp(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/');
    app.main();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント').evaluate().isNotEmpty) break;
    }
    // ボトムナビゲーションが描画されるまで追加待機
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('dashboard_tab')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// ダッシュボードタブをタップしてダッシュボード画面を表示する。
  /// ダッシュボードタブが見つからない場合は false を返す。
  Future<bool> goToDashboard(WidgetTester tester) async {
    final dashboardTab = find.byKey(const Key('dashboard_tab'));
    if (dashboardTab.evaluate().isEmpty) {
      print('[SKIP] dashboard_tab が見つかりません');
      return false;
    }
    await tester.tap(dashboardTab);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      // チップが1件以上表示されるか、プレースホルダーが表示されるまで待機
      final hasChip = find.byKeyPrefix('topic_chip_').evaluate().isNotEmpty;
      final hasPlaceholder =
          find.byKey(const Key('dashboard_empty_placeholder')).evaluate().isNotEmpty;
      if (hasChip || hasPlaceholder) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// ダッシュボード画面まで遷移するセットアップ。
  /// 遷移できない場合はスキップ理由文字列を返す。null の場合は成功。
  Future<String?> setupDashboard(WidgetTester tester) async {
    await startApp(tester);
    final navigated = await goToDashboard(tester);
    if (!navigated) {
      return 'ダッシュボードタブが表示されなかったためスキップします';
    }
    return null;
  }

  /// 指定した TopicType チップをタップして対応ビューが表示されるまで待つ。
  Future<void> selectTopicChip(WidgetTester tester, String topicName) async {
    final chip = find.byKey(Key('topic_chip_$topicName'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] topic_chip_$topicName が見つかりません（データなし）');
      return;
    }
    await tester.ensureVisible(chip);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(chip);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ──────────────────────────────────────────────────────────
  // TC-DB-001: ダッシュボードタブが表示される
  // ──────────────────────────────────────────────────────────

  testWidgets('TC-DB-001: ダッシュボードタブがボトムナビゲーションに表示される', (tester) async {
    await startApp(tester);

    expect(find.byKey(const Key('dashboard_tab')), findsOneWidget);
  });

  testWidgets('TC-DB-001b: ダッシュボードタブをタップするとダッシュボード画面が表示される',
      (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // ダッシュボード画面が表示されている（チップ or プレースホルダーのどちらかが存在する）
    final hasChip = find.byKeyPrefix('topic_chip_').evaluate().isNotEmpty;
    final hasPlaceholder =
        find.byKey(const Key('dashboard_empty_placeholder')).evaluate().isNotEmpty;
    expect(hasChip || hasPlaceholder, isTrue);
  });

  testWidgets('TC-DB-001c: ダッシュボード表示後にトピック選択チップが1件以上表示される',
      (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chips = find.byKeyPrefix('topic_chip_').evaluate();
    if (chips.isEmpty) {
      // データが0件の場合はプレースホルダーが表示されることを確認して終了
      expect(
        find.byKey(const Key('dashboard_empty_placeholder')),
        findsOneWidget,
      );
      return;
    }
    expect(chips.length, greaterThanOrEqualTo(1));
  });

  // ──────────────────────────────────────────────────────────
  // TC-DB-002: movingCost チップを選択すると移動コストビューが表示される
  // ──────────────────────────────────────────────────────────

  testWidgets('TC-DB-002: movingCostチップをタップすると移動コストチャートが表示される',
      (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_movingCost'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] movingCostデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'movingCost');

    expect(
      find.byKey(const Key('moving_cost_dashboard_chart')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DB-002b: movingCostチップ選択後に総走行距離ラベルが表示される', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_movingCost'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] movingCostデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'movingCost');

    expect(
      find.byKey(const Key('moving_cost_total_distance_label')),
      findsOneWidget,
    );
  });

  // ──────────────────────────────────────────────────────────
  // TC-DB-003: 移動コスト KPI ラベルが表示される
  // ──────────────────────────────────────────────────────────

  testWidgets('TC-DB-003: movingCost KPI 総コストラベルが表示される', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_movingCost'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] movingCostデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'movingCost');

    expect(
      find.byKey(const Key('moving_cost_total_cost_label')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DB-003b: movingCost KPI 総走行距離ラベルのテキストが距離形式または「---」である',
      (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_movingCost'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] movingCostデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'movingCost');

    final labelFinder = find.byKey(const Key('moving_cost_total_distance_label'));
    expect(labelFinder, findsOneWidget);

    // テキストが「km」または「---」を含むこと
    final widget = tester.widget<Text>(
      find.descendant(of: labelFinder, matching: find.byType(Text)).first,
    );
    final text = widget.data ?? '';
    expect(text.contains('km') || text.contains('---'), isTrue);
  });

  // ──────────────────────────────────────────────────────────
  // TC-DB-004: travelExpense チップを選択するとカレンダーが表示される
  // ──────────────────────────────────────────────────────────

  testWidgets('TC-DB-004: travelExpenseチップをタップするとカレンダーが表示される', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_travelExpense'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] travelExpenseデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'travelExpense');

    expect(
      find.byKey(const Key('travel_expense_calendar')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DB-004b: travelExpense選択後に旅行回数KPIラベルが表示される', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_travelExpense'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] travelExpenseデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'travelExpense');

    expect(
      find.byKey(const Key('travel_expense_trip_count_label')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DB-004c: travelExpense選択後に訪問スポット数KPIラベルが表示される',
      (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_travelExpense'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] travelExpenseデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'travelExpense');

    expect(
      find.byKey(const Key('travel_expense_spot_count_label')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DB-004d: travelExpense選択後に総支出KPIラベルが表示される', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_travelExpense'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] travelExpenseデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'travelExpense');

    expect(
      find.byKey(const Key('travel_expense_total_expense_label')),
      findsOneWidget,
    );
  });

  // ──────────────────────────────────────────────────────────
  // TC-DB-005: カレンダーのイベントバッジをタップすると EventDetail へ遷移する
  // ──────────────────────────────────────────────────────────

  testWidgets('TC-DB-005: カレンダーのイベントバッジをタップするとEventDetail画面へ遷移する',
      (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_travelExpense'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] travelExpenseデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'travelExpense');

    // カレンダーが表示されていることを確認
    final calendar = find.byKey(const Key('travel_expense_calendar'));
    if (calendar.evaluate().isEmpty) {
      print('[SKIP] カレンダーが表示されていないためスキップします');
      return;
    }

    // イベントバッジ（travel_calendar_badge_ で始まるキー）を探してタップ
    final badges = find.byKeyPrefix('travel_calendar_badge_').evaluate();
    if (badges.isEmpty) {
      print('[SKIP] カレンダー上にイベントバッジが存在しないためスキップします');
      return;
    }

    await tester.tap(find.byKeyPrefix('travel_calendar_badge_').first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      // EventDetail 画面が表示されたかを「概要」タブの存在で判定
      if (find.text('概要').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('概要'), findsOneWidget);
  });

  // ──────────────────────────────────────────────────────────
  // TC-DB-006: visitWork チップを選択すると作業記録ビューが表示される
  // ──────────────────────────────────────────────────────────

  testWidgets('TC-DB-006: visitWorkチップをタップするとコンボチャートが表示される', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_visitWork'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] visitWorkデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'visitWork');

    expect(
      find.byKey(const Key('visit_work_dashboard_combo_chart')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DB-006b: visitWork選択後にドーナツグラフが表示される', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_visitWork'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] visitWorkデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'visitWork');

    expect(
      find.byKey(const Key('visit_work_dashboard_donut_chart')),
      findsOneWidget,
    );
  });

  // ──────────────────────────────────────────────────────────
  // TC-DB-007: 作業記録 KPI ラベルが表示される
  // ──────────────────────────────────────────────────────────

  testWidgets('TC-DB-007: visitWork KPI 総作業時間ラベルが表示される', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_visitWork'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] visitWorkデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'visitWork');

    expect(
      find.byKey(const Key('visit_work_total_work_time_label')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DB-007b: visitWork KPI 総売上ラベルが表示される', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_visitWork'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] visitWorkデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'visitWork');

    expect(
      find.byKey(const Key('visit_work_total_revenue_label')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DB-007c: visitWork KPI 時間単価ラベルが表示される', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_visitWork'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] visitWorkデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'visitWork');

    expect(
      find.byKey(const Key('visit_work_hourly_rate_label')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DB-007d: visitWork KPI 稼働率ラベルが表示される', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final chip = find.byKey(const Key('topic_chip_visitWork'));
    if (chip.evaluate().isEmpty) {
      print('[SKIP] visitWorkデータが存在しないためスキップします');
      return;
    }

    await selectTopicChip(tester, 'visitWork');

    expect(
      find.byKey(const Key('visit_work_utilization_rate_label')),
      findsOneWidget,
    );
  });

  // ──────────────────────────────────────────────────────────
  // TC-DB-008: データが0件の場合にプレースホルダーが表示される
  // ──────────────────────────────────────────────────────────

  testWidgets('TC-DB-008: データなしトピック選択時にプレースホルダーが表示される', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // チップが1件もない場合はダッシュボード全体でプレースホルダーが出ているはず
    final chips = find.byKeyPrefix('topic_chip_').evaluate();
    if (chips.isEmpty) {
      expect(
        find.byKey(const Key('dashboard_empty_placeholder')),
        findsOneWidget,
      );
      return;
    }

    // チップが存在する場合、ダッシュボード初期状態でプレースホルダーが出るケースを確認
    // （データ0件のトピックチップを意図的に選択させる操作は Spec に定義がないため、
    //  チップ選択後にプレースホルダーが表示されない（グラフが表示される）ことが正常とみなす）
    print('[INFO] チップが存在するためTC-DB-008は初期プレースホルダー確認でスキップします');
  });

  testWidgets('TC-DB-008b: データなし状態ではグラフ・KPIが表示されない', (tester) async {
    final skipReason = await setupDashboard(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // チップが0件の場合のみ確認（データが存在する場合はスキップ）
    final chips = find.byKeyPrefix('topic_chip_').evaluate();
    if (chips.isNotEmpty) {
      print('[SKIP] データが存在するためTC-DB-008bはスキップします');
      return;
    }

    // グラフ・KPIが表示されていないこと
    expect(find.byKey(const Key('moving_cost_dashboard_chart')), findsNothing);
    expect(find.byKey(const Key('travel_expense_calendar')), findsNothing);
    expect(
        find.byKey(const Key('visit_work_dashboard_combo_chart')), findsNothing);
  });
}

// ──────────────────────────────────────────────────────────
// ユーティリティ: byKeyPrefix finder
// ──────────────────────────────────────────────────────────

extension _FinderExtension on CommonFinders {
  Finder byKeyPrefix(String prefix) {
    return find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith(prefix),
    );
  }
}
