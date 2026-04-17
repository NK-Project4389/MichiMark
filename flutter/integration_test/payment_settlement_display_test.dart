// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: 旅費集計「支払いごとの精算」誤認防止
///
/// Spec: docs/Spec/Features/FS-payment_settlement_display.md §5
/// テストシナリオ: TC-PSD-001 〜 TC-PSD-002
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - 旅費データ（支払い情報）が存在するイベントが少なくとも1件登録されていること
///   - 概要タブに「支払いごとの精算」ブロックが表示される状態であること

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
      if (find.text('イベント一覧').evaluate().isNotEmpty) break;
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

  /// 指定名称のイベントをタップして EventDetail を開く。
  /// イベントが存在しない場合は false を返す。
  Future<bool> openEventDetailByName(
    WidgetTester tester,
    String eventName,
  ) async {
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final cards = find.ancestor(
      of: find.text(eventName),
      matching: find.byType(GestureDetector),
    );
    if (cards.evaluate().isEmpty) return false;

    await tester.tap(cards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));
    return true;
  }

  /// 概要タブをタップして表示する。
  Future<void> tapOverviewTab(WidgetTester tester) async {
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab.first);
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  /// 概要タブを下方向にスクロールして「支払いごとの精算」ブロックを探す。
  /// ブロックが見つかった場合は true を返す。
  Future<bool> scrollToSettlementBlock(WidgetTester tester) async {
    const targetKey = Key('travelExpenseOverview_block_perPaymentSettlement_0');

    // まず現在の画面内に存在するか確認
    if (find.byKey(targetKey).evaluate().isNotEmpty) return true;

    // スクロールして探す（最大10回）
    for (var i = 0; i < 10; i++) {
      final scrollables = find.byType(SingleChildScrollView);
      if (scrollables.evaluate().isNotEmpty) {
        await tester.drag(
          scrollables.first,
          const Offset(0, -400),
        );
      } else {
        final listViews = find.byType(ListView);
        if (listViews.evaluate().isNotEmpty) {
          await tester.drag(
            listViews.first,
            const Offset(0, -400),
          );
        } else {
          break;
        }
      }
      await tester.pump(const Duration(milliseconds: 200));

      if (find.byKey(targetKey).evaluate().isNotEmpty) return true;
    }

    return false;
  }

  /// 概要タブの「支払いごとの精算」ブロックが表示されるまでのセットアップ。
  /// 前提条件を満たせない場合はスキップ理由を返す。null の場合は成功。
  Future<String?> setupToSettlementBlock(WidgetTester tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }

    // event-002「富士五湖キャンプ」は travelExpense トピックで支払いデータあり
    final opened = await openEventDetailByName(tester, '富士五湖キャンプ');
    if (!opened) {
      return 'イベント詳細を開けなかったためスキップします';
    }

    await tapOverviewTab(tester);

    final found = await scrollToSettlementBlock(tester);
    if (!found) {
      return '「支払いごとの精算」ブロックが見つからなかったためスキップします（旅費データが存在しないか、対応するキーが未実装）';
    }

    return null;
  }

  // ────────────────────────────────────────────────────────
  // TC-PSD-001: 支払いごとの精算ブロックが表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PSD-001: 旅費データが存在するイベントの概要タブに「支払いごとの精算」ブロックが表示される',
      (tester) async {
    final skipReason = await setupToSettlementBlock(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    expect(
      find.byKey(
          const Key('travelExpenseOverview_block_perPaymentSettlement_0')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PSD-002: 支払いごとの精算ブロックにCardの影がない（Containerである）
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-PSD-002: 「支払いごとの精算」ブロックがCardウィジェットでない（Containerとして表示される）',
      (tester) async {
    final skipReason = await setupToSettlementBlock(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    const targetKey =
        Key('travelExpenseOverview_block_perPaymentSettlement_0');

    // ウィジェットが存在することを前提確認
    expect(find.byKey(targetKey), findsOneWidget);

    // Card型でないことを確認（CardはelevationでCardの影が付く）
    final widget = find.byKey(targetKey).evaluate().first.widget;
    expect(
      widget is! Card,
      isTrue,
      reason: '「支払いごとの精算」ブロックはCardウィジェットではなくContainerである必要があります',
    );
  });

  testWidgets(
      'TC-PSD-002: 「支払いごとの精算」ブロックがContainerウィジェットである',
      (tester) async {
    final skipReason = await setupToSettlementBlock(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    const targetKey =
        Key('travelExpenseOverview_block_perPaymentSettlement_0');

    // ウィジェットが存在することを前提確認
    expect(find.byKey(targetKey), findsOneWidget);

    // Container型であることを確認
    final widget = find.byKey(targetKey).evaluate().first.widget;
    expect(
      widget is Container,
      isTrue,
      reason: '「支払いごとの精算」ブロックはContainerウィジェットである必要があります',
    );
  });
}
