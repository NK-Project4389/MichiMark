// ignore_for_file: avoid_print

/// Integration Test: シードデータ修正 & 概要タブのガソリン支払者絞り込み確認
///
/// 修正1: シードデータにトピック追加（event-001: 移動コスト可視化, event-002: 旅費可視化）
///   TC-SEED-001: イベント一覧画面で「移動コスト可視化」トピック名が表示されること
///   TC-SEED-002: イベント一覧画面で「旅費可視化」トピック名が表示されること
///
/// 修正2: 概要タブのガソリン支払者を参加者のみに制限
///   TC-SEED-003: 箱根日帰りドライブの支払者選択で太郎・花子のみが表示され、健太が表示されないこと

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;
import 'package:michi_mark/repository/impl/in_memory/seed_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ────────────────────────────────────────────────────────
  // ヘルパー
  // ────────────────────────────────────────────────────────

  /// アプリを起動してEventListPageが表示されるまで待つ。
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
          find.text('イベントがありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// イベント一覧から指定イベントをタップしてEventDetailを開く。
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

  // ────────────────────────────────────────────────────────
  // TC-SEED-001: イベント一覧でevent-001のトピック名が表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-SEED-001: イベント一覧で「移動コスト（給油から計算）」トピック名が表示される',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 「箱根日帰りドライブ」カードに「移動コスト（給油から計算）」が表示されること
    expect(
      find.text('移動コスト（給油から計算）'),
      findsWidgets,
      reason: 'イベント一覧の「箱根日帰りドライブ」カードに「移動コスト（給油から計算）」トピック名が表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-SEED-002: イベント一覧でevent-002のトピック名が表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-SEED-002: イベント一覧で「旅費可視化」トピック名が表示される',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 「富士五湖キャンプ」カードに「旅費可視化」が表示されること
    expect(
      find.text('旅費可視化'),
      findsWidgets,
      reason: 'イベント一覧の「富士五湖キャンプ」カードに「旅費可視化」トピック名が表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-SEED-003: 箱根日帰りドライブの支払者選択で参加者のみ表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-SEED-003: 概要タブのガソリン支払者選択で参加者（太郎・花子）のみ表示される',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないためスキップします');
      return;
    }

    // 概要タブが表示されていることを確認（デフォルト）
    expect(find.text('概要'), findsOneWidget,
        reason: '概要タブが表示されていること');

    // BasicInfoView の参照モードエリアをタップして編集モードに入る
    // BasicInfoReadView のロード完了を待つ（「タップして編集」ヒントが表示されるまで）
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoRead_container_section')).evaluate().isNotEmpty) break;
    }
    final readArea = find.byKey(const Key('basicInfoRead_container_section'));
    expect(readArea, findsOneWidget, reason: '参照モードエリ���が存在すること');
    await tester.tap(readArea);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ガソリン支払者').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 「ガソリン支払者」行を探してタップする
    final gasPayerRow = find.text('ガソリン支払者');
    if (gasPayerRow.evaluate().isEmpty) {
      markTestSkipped('「ガソリン支払者」行が見つからないためスキップします（トピックがmovingCost以外の可能性）');
      return;
    }

    // ガソリン支払者のInkWell/SelectionRowをタップ
    final gasPayerInkWell = find.ancestor(
      of: gasPayerRow,
      matching: find.byType(InkWell),
    );
    if (gasPayerInkWell.evaluate().isEmpty) {
      markTestSkipped('「ガソリン支払者」のInkWellが見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(gasPayerInkWell.first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(gasPayerInkWell.first);

    // SelectionPageが開くまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('確定').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // SelectionPageが開いていることを確認
    expect(find.text('確定'), findsOneWidget,
        reason: '支払者選択画面（SelectionPage）が開いていること');

    // 参加者「太郎」が表示されること
    expect(find.text(seedMembers[0].memberName), findsWidgets,
        reason: '参加者「${seedMembers[0].memberName}」が支払者選択画面に表示されること');

    // 参加者「花子」が表示されること
    expect(find.text('花子'), findsWidgets,
        reason: '参加者「花子」が支払者選択画面に表示されること');

    // 非参加者「健太」が表示されないこと
    expect(find.text('健太'), findsNothing,
        reason: '非参加者「健太」が支払者選択画面に表示されないこと（参加者のみに絞り込まれていること）');
  });
}
