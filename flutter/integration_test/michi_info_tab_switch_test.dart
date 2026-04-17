// ignore_for_file: avoid_print

/// Integration Test: MichiInfo タブ切り替え時追加モード終了（B-5）
///
/// 要件: docs/Requirements/REQ-DRAFT-michi_info_tab_switch_add_mode.md
/// テストシナリオ: TC-B5-001

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
      if (find.text('イベント一覧').evaluate().isNotEmpty) break;
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(ListView).evaluate().isNotEmpty ||
          find.text('イベントがありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// EventDetail の「ミチ」タブに移動する。
  /// 前提: EventDetailPage が表示済みであること。
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

  /// 追加モード（InsertMode）に入る。
  /// FAB をタップして InsertMode になることを確認する。
  /// InsertMode 中は FAB の Icon が Icons.close になる。
  Future<void> enterInsertMode(WidgetTester tester) async {
    // FAB が表示されるまで待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }

    // FAB をタップして InsertMode に切り替える
    await tester.tap(find.byType(FloatingActionButton));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      // InsertMode 中はインジケーター (michiInfo_button_insertIndicator_head) が表示される
      if (find.byKey(const Key('michiInfo_button_insertIndicator_head')).evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ────────────────────────────────────────────────────────
  // TC-B5-001: タブ切り替え時に追加モードが終了すること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-B5-001: ミチタブでFABタップして追加モードに入り、別タブに切り替えると追加モードが終了し、再度ミチタブに戻っても追加モードがOFFであること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // EventDetail を開く（先頭のイベントを使用）
    final eventCards = find.byType(GestureDetector);
    if (eventCards.evaluate().isEmpty) {
      markTestSkipped('イベントカードが見つからないためスキップします');
      return;
    }
    await tester.tap(eventCards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // ── Step 1: ミチタブに移動 ──
    final reachedMichi = await goToMichiTab(tester);
    expect(reachedMichi, isTrue, reason: '「ミチ」タブが存在すること');

    // ── Step 2: FAB（追加ボタン）が表示されることを確認 ──
    expect(
      find.byType(FloatingActionButton),
      findsOneWidget,
      reason: 'ミチタブにFABが表示されること',
    );

    // ── Step 3: FAB をタップして追加モードに入る ──
    await enterInsertMode(tester);

    // 追加モード中はインジケーター（michiInfo_button_insertIndicator_head）が表示されること
    expect(
      find.byKey(const Key('michiInfo_button_insertIndicator_head')),
      findsOneWidget,
      reason: '追加モード中に先頭インジケーターが表示されること',
    );

    // ── Step 4: 別タブ（概要）に切り替える ──
    final overviewTab = find.text('概要');
    expect(overviewTab, findsOneWidget, reason: '「概要」タブが表示されること');
    await tester.tap(overviewTab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // 概要タブのコンテンツが表示されるまで待つ
      if (find.text('距離').evaluate().isNotEmpty ||
          find.text('費用').evaluate().isNotEmpty ||
          find.text('開始日').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // ── Step 5: ミチタブに戻る ──
    final michiTabAgain = find.text('ミチ');
    expect(michiTabAgain, findsOneWidget, reason: '「ミチ」タブに戻れること');
    await tester.tap(michiTabAgain);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // ── Step 6: 追加モードが終了していることを確認 ──
    // 追加モードが終了している場合、michiInfo_button_insertIndicator_head は非表示になる
    expect(
      find.byKey(const Key('michiInfo_button_insertIndicator_head')),
      findsNothing,
      reason: 'ミチタブに戻った後は追加モードが終了していること（インジケーターが非表示）',
    );

    // FAB が通常モード（Icons.add）で表示されること
    // T-205実装後にキー確認要: FABにKeyが設定された場合はKeyで検索すること
    expect(
      find.byType(FloatingActionButton),
      findsOneWidget,
      reason: 'ミチタブに戻った後もFABが表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-B5-002: 追加モード中に支払タブへ切り替えても追加モードが終了すること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-B5-002: 追加モード中に支払タブへ切り替えた後、ミチタブに戻ると追加モードが終了していること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // EventDetail を開く（先頭のイベントを使用）
    final eventCards = find.byType(GestureDetector);
    if (eventCards.evaluate().isEmpty) {
      markTestSkipped('イベントカードが見つからないためスキップします');
      return;
    }
    await tester.tap(eventCards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // ミチタブに移動
    final reachedMichi = await goToMichiTab(tester);
    expect(reachedMichi, isTrue, reason: '「ミチ」タブが存在すること');

    // FAB をタップして追加モードに入る
    await enterInsertMode(tester);

    // 追加モード中はインジケーターが表示されること
    expect(
      find.byKey(const Key('michiInfo_button_insertIndicator_head')),
      findsOneWidget,
      reason: '追加モード中に先頭インジケーターが表示されること',
    );

    // 支払タブに切り替える
    final paymentTab = find.text('支払');
    expect(paymentTab, findsOneWidget, reason: '「支払」タブが表示されること');
    await tester.tap(paymentTab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 500));

    // ミチタブに戻る
    final michiTabAgain = find.text('ミチ');
    expect(michiTabAgain, findsOneWidget, reason: '「ミチ」タブに戻れること');
    await tester.tap(michiTabAgain);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 追加モードが終了していることを確認（インジケーター非表示）
    expect(
      find.byKey(const Key('michiInfo_button_insertIndicator_head')),
      findsNothing,
      reason: '支払タブ切り替え後にミチタブへ戻ると追加モードが終了していること',
    );
  });
}
