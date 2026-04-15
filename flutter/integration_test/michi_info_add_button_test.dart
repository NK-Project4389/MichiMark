// ignore_for_file: avoid_print

/// Integration Test: MichiInfo追加ボタン改善・集計ページ整理
///
/// Spec: docs/Spec/Features/michi_info_add_button_and_aggregation_spec.md §7
/// テストシナリオ: TC-MAB-001 〜 TC-MAB-003

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ────────────────────────────────────────────────────────
  // ヘルパー
  // ────────────────────────────────────────────────────────

  /// アプリを起動して EventListPage が表示されるまで待つ。
  Future<void> startApp(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/');
    app.main();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント').evaluate().isNotEmpty) break;
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(ListView).evaluate().isNotEmpty ||
          find.text('イベントがありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// イベント一覧から指定イベントをタップして EventDetail を開く。
  Future<bool> openEventDetail(
    WidgetTester tester,
    String eventName,
  ) async {
    final cards = find.ancestor(
      of: find.text(eventName),
      matching: find.byType(GestureDetector),
    );
    if (cards.evaluate().isEmpty) return false;
    await tester.tap(cards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty ||
          find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// EventDetail の「ミチ」タブに移動する。
  Future<bool> goToMichiTab(WidgetTester tester) async {
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return false;
    await tester.tap(michiTab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// EventDetail の「概要」タブに移動する。
  Future<bool> goToOverviewTab(WidgetTester tester) async {
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isEmpty) return false;
    await tester.tap(overviewTab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('距離').evaluate().isNotEmpty ||
          find.text('費用').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  // ────────────────────────────────────────────────────────
  // TC-MAB-001: movingCost FABタップでInsertMode→インジケータータップでBottomSheet表示
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAB-001: movingCostイベントのFABタップでInsertMode→インジケータータップでBottomSheet表示（地点・区間の両方）',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 箱根日帰りドライブ（event-001 / movingCost）を開く
    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    expect(opened, isTrue, reason: '「箱根日帰りドライブ」のEventDetailが開けること');

    // ミチタブに移動
    final reached = await goToMichiTab(tester);
    expect(reached, isTrue, reason: '「ミチ」タブが存在すること');

    // FABが存在することを確認
    expect(
      find.byType(FloatingActionButton),
      findsOneWidget,
      reason: 'MichiInfoにFABが表示されること',
    );

    // FABをタップ → InsertMode に切り替わる
    await tester.tap(find.byType(FloatingActionButton));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.byIcon(Icons.add_circle).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // InsertMode になりインジケーター（add_circle_outline）が表示されること
    expect(
      find.byIcon(Icons.add_circle),
      findsWidgets,
      reason: 'InsertMode中にインジケーターが表示されること',
    );

    // インジケーターをタップ → BottomSheetが表示される
    await tester.tap(find.byIcon(Icons.add_circle).first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.text('地点を追加').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // ボトムシートに地点・区間の両方が表示されること
    expect(
      find.text('地点を追加'),
      findsOneWidget,
      reason: 'ボトムシートに「地点を追加」が表示されること',
    );
    expect(
      find.text('区間を追加'),
      findsOneWidget,
      reason: 'ボトムシートに「区間を追加」が表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MAB-002: travelExpense FABタップでInsertMode→インジケータータップでMarkDetail直接遷移
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAB-002: travelExpenseイベントのFABタップでInsertMode→インジケータータップでMarkDetail直接遷移（BottomSheet非表示）',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 富士五湖キャンプ（event-002 / travelExpense）を開く
    final opened = await openEventDetail(tester, '富士五湖キャンプ');
    expect(opened, isTrue, reason: '「富士五湖キャンプ」のEventDetailが開けること');

    // ミチタブに移動
    final reached = await goToMichiTab(tester);
    expect(reached, isTrue, reason: '「ミチ」タブが存在すること');

    // FABが存在することを確認
    expect(
      find.byType(FloatingActionButton),
      findsOneWidget,
      reason: 'MichiInfoにFABが表示されること',
    );

    // FABをタップ → InsertMode に切り替わる
    await tester.tap(find.byType(FloatingActionButton));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.byIcon(Icons.add_circle).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // InsertMode になりインジケーターが表示されること
    expect(
      find.byIcon(Icons.add_circle),
      findsWidgets,
      reason: 'InsertMode中にインジケーターが表示されること',
    );

    // インジケーターをタップ → BottomSheetを経由せず MarkDetail 画面へ直接遷移する
    await tester.tap(find.byIcon(Icons.add_circle).first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // MarkDetail 画面が開いたことを「保存」または「名称」テキストで確認
      if (find.text('保存').evaluate().isNotEmpty ||
          find.text('名称').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // ボトムシートは表示されないこと（「地点を追加」「区間を追加」が表示されない）
    expect(
      find.text('地点を追加'),
      findsNothing,
      reason: 'travelExpenseではインジケータータップ後にBottomSheet「地点を追加」が表示されないこと',
    );
    expect(
      find.text('区間を追加'),
      findsNothing,
      reason: 'travelExpenseではインジケータータップ後にBottomSheet「区間を追加」が表示されないこと',
    );

    // MarkDetail 画面（地点追加画面）が直接表示されること
    expect(
      find.text('保存'),
      findsOneWidget,
      reason: 'travelExpenseではインジケータータップ後にMarkDetail画面が直接表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MAB-003: MovingCostOverviewViewに時間セクションが表示されないこと
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MAB-003: MovingCostOverviewViewに時間セクションが表示されないこと',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 箱根日帰りドライブ（event-001 / movingCost）を開く
    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    expect(opened, isTrue, reason: '「箱根日帰りドライブ」のEventDetailが開けること');

    // 概要タブに移動
    final reached = await goToOverviewTab(tester);
    expect(reached, isTrue, reason: '「概要」タブが存在すること');

    // 時間セクション関連が表示されないこと
    expect(
      find.text('時間'),
      findsNothing,
      reason: '「時間」セクションタイトルが表示されないこと',
    );
    expect(
      find.text('移動時間'),
      findsNothing,
      reason: '「移動時間」ラベルが表示されないこと',
    );
    expect(
      find.text('作業時間'),
      findsNothing,
      reason: '「作業時間」ラベルが表示されないこと',
    );
    expect(
      find.text('休憩時間'),
      findsNothing,
      reason: '「休憩時間」ラベルが表示されないこと',
    );
    expect(
      find.text('滞留時間'),
      findsNothing,
      reason: '「滞留時間」ラベルが表示されないこと',
    );

    // 距離セクションが表示されること
    expect(
      find.text('距離'),
      findsOneWidget,
      reason: '「距離」セクションが表示されること',
    );

    // 費用セクションが表示されること
    expect(
      find.text('費用'),
      findsOneWidget,
      reason: '「費用」セクションが表示されること',
    );
  });
}
