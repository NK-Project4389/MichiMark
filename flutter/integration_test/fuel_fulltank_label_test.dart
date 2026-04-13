// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: 給油集計「満タン給油で算出」文言表示
///
/// Spec: docs/Spec/Features/FS-fuel_aggregation_fulltank_label.md §6
/// テストシナリオ: TC-FFL-001 〜 TC-FFL-002
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - event-001「箱根日帰りドライブ」（isFuel=true のMarkLink ml-005 あり）が存在すること（TC-FFL-001用）
///   - event-002「富士五湖キャンプ」（isFuel=true のMarkLink なし）が存在すること（TC-FFL-002用）

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ────────────────────────────────────────────────────────
  // ヘルパー関数
  // ────────────────────────────────────────────────────────

  /// アプリを起動してイベント一覧が表示されるまで待つ。
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
          find.text('イベントがありません').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// イベント一覧から指定名のイベントをタップして EventDetail の概要タブを開く。
  /// イベントが存在しない場合は false を返す。
  Future<bool> openOverviewTabByEventName(
      WidgetTester tester, String eventName) async {
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    // 指定名のイベントカードをスクロールして探す
    for (var i = 0; i < 10; i++) {
      if (find.text(eventName).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isEmpty) break;
      await tester.drag(listViews.first, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 200));
    }

    if (find.text(eventName).evaluate().isEmpty) return false;

    await tester.tap(find.text(eventName).first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));
    return true;
  }

  /// 概要タブの集計セクションが表示されるまでスクロールする。
  /// `Key('movingCostOverview_text_fulltankLabel')` または集計セクション全体が
  /// 表示されるまでスクロールを試みる。
  Future<void> scrollToAggregationSection(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      // 「満タン給油で算出」ラベルが見えたら終了
      if (find
          .byKey(const Key('movingCostOverview_text_fulltankLabel'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      // 集計セクション全体（ガソリン代やガソリン量など）を探しながらスクロール
      final scrollable = find.byType(SingleChildScrollView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
      } else {
        final listViews = find.byType(ListView);
        if (listViews.evaluate().isNotEmpty) {
          await tester.drag(listViews.first, const Offset(0, -300));
        }
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  // ────────────────────────────────────────────────────────
  // TC-FFL-001: 給油データありのイベント概要タブに「満タン給油で算出」が表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-FFL-001: 給油データ（isFuel=true）があるイベントの概要タブに「満タン給油で算出」が表示される',
      (tester) async {
    await startApp(tester);

    // event-001「箱根日帰りドライブ」は isFuel=true の MarkLink (ml-005) を持つ
    const targetEventName = '箱根日帰りドライブ';
    final opened =
        await openOverviewTabByEventName(tester, targetEventName);
    if (!opened) {
      print('[SKIP] $targetEventName が存在しないためスキップします');
      return;
    }

    // 集計セクションが表示されるまでスクロール
    await scrollToAggregationSection(tester);

    expect(
      find.byKey(const Key('movingCostOverview_text_fulltankLabel')),
      findsOneWidget,
      reason: '給油データがあるイベントの概要タブ集計セクションに「満タン給油で算出」が表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-FFL-001 (テキスト確認): 表示されるテキストが「満タン給油で算出」である
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-FFL-001: 「満タン給油で算出」ウィジェットのテキスト内容が正しい',
      (tester) async {
    await startApp(tester);

    const targetEventName = '箱根日帰りドライブ';
    final opened =
        await openOverviewTabByEventName(tester, targetEventName);
    if (!opened) {
      print('[SKIP] $targetEventName が存在しないためスキップします');
      return;
    }

    await scrollToAggregationSection(tester);

    expect(
      find.text('満タン給油で算出'),
      findsOneWidget,
      reason: '「満タン給油で算出」テキストが1つだけ表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-FFL-002: 給油データなしのイベント概要タブに「満タン給油で算出」が表示されない
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-FFL-002: 給油データ（isFuel=true）がないイベントの概要タブに「満タン給油で算出」が表示されない',
      (tester) async {
    await startApp(tester);

    // event-002「富士五湖キャンプ」は isFuel=true の MarkLink を持たない
    const targetEventName = '富士五湖キャンプ';
    final opened =
        await openOverviewTabByEventName(tester, targetEventName);
    if (!opened) {
      print('[SKIP] $targetEventName が存在しないためスキップします');
      return;
    }

    // 集計セクションが表示されるまでスクロール（ラベルが出ないことを確認するため最大限スクロール）
    for (var i = 0; i < 10; i++) {
      final scrollable = find.byType(SingleChildScrollView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
      } else {
        final listViews = find.byType(ListView);
        if (listViews.evaluate().isNotEmpty) {
          await tester.drag(listViews.first, const Offset(0, -300));
        }
      }
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(
      find.byKey(const Key('movingCostOverview_text_fulltankLabel')),
      findsNothing,
      reason: '給油データがないイベントの概要タブに「満タン給油で算出」Widgetが存在しないこと',
    );
  });

  testWidgets(
      'TC-FFL-002: 給油データがないイベントの概要タブに「満タン給油で算出」テキストが表示されない',
      (tester) async {
    await startApp(tester);

    const targetEventName = '富士五湖キャンプ';
    final opened =
        await openOverviewTabByEventName(tester, targetEventName);
    if (!opened) {
      print('[SKIP] $targetEventName が存在しないためスキップします');
      return;
    }

    // 集計セクションまでスクロール
    for (var i = 0; i < 10; i++) {
      final scrollable = find.byType(SingleChildScrollView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
      } else {
        final listViews = find.byType(ListView);
        if (listViews.evaluate().isNotEmpty) {
          await tester.drag(listViews.first, const Offset(0, -300));
        }
      }
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(
      find.text('満タン給油で算出'),
      findsNothing,
      reason: '給油データがないイベントに「満タン給油で算出」テキストが存在しないこと',
    );
  });
}
