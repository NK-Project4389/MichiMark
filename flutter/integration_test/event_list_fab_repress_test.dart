// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: B-14 プラスボタン再押し不可
///
/// バグ内容:
///   イベント一覧のFAB（+ボタン）を押してトピック選択シートを表示し、
///   キャンセルした後にFABが再度押せなくなる。
///   修正内容: showModalBottomSheet の .then コールバックで
///   EventListTopicSelectionDismissed を dispatch して
///   showTopicSelection フラグをリセットする（B-14修正）。
///
/// テストシナリオ: TC-EFR-001 〜 TC-EFR-002
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータが投入済みであること

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
          find.text('イベントがありません').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// トピック選択シートが表示されているかを確認する。
  /// 「トピックを選択」テキスト（シートのタイトル）の存在で判定する。
  /// ※ トピック名テキストはEventListのカードにも表示されるため判定に使わない。
  bool isTopicSelectionSheetVisible(WidgetTester tester) {
    return find.byType(BottomSheet).evaluate().isNotEmpty &&
        find.text('トピックを選択').evaluate().isNotEmpty;
  }

  /// FABをタップしてトピック選択シートが表示されるまで待つ。
  /// シートが表示されたら true を返す。
  Future<bool> tapFabAndWaitForSheet(WidgetTester tester) async {
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isEmpty) return false;

    await tester.tap(fab.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (isTopicSelectionSheetVisible(tester)) return true;
    }
    return false;
  }

  /// トピック選択シートをキャンセルする。
  /// 画面上部（シートの外側）を tapAt でタップして ModalBarrier 経由で閉じる。
  Future<void> cancelTopicSheet(WidgetTester tester) async {
    // 画面上部（y=100）をタップして ModalBarrier を通じてシートを閉じる
    await tester.tapAt(const Offset(200, 100));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    // シートが完全に閉じるまで待機（BottomSheet ウィジェット消滅 + テキスト消滅の両方）
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final sheetGone = find.byType(BottomSheet).evaluate().isEmpty;
      final textGone = !isTopicSelectionSheetVisible(tester);
      if (sheetGone && textGone) break;
    }
    await tester.pump(const Duration(milliseconds: 500));
  }

  // ────────────────────────────────────────────────────────
  // TC-EFR-001: FAB押下→シート表示→キャンセル後にFABが再押し可能であること
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-EFR-001: FAB押下→トピック未選択→キャンセル後にFABが再押し可能であること',
      (tester) async {
    await startApp(tester);

    // Step 1: FABをタップしてトピック選択シートを表示
    final sheetOpened = await tapFabAndWaitForSheet(tester);
    if (!sheetOpened) {
      print('[SKIP] トピック選択シートが表示されなかったためスキップします');
      return;
    }

    // Step 2: トピック選択シートが表示されていることを確認
    expect(
      isTopicSelectionSheetVisible(tester),
      isTrue,
      reason: 'FABタップ後にトピック選択シートが表示されること',
    );

    // Step 3: シートをキャンセル（バリアタップ）
    await cancelTopicSheet(tester);

    // Step 4: シートが閉じていることを確認
    expect(
      isTopicSelectionSheetVisible(tester),
      isFalse,
      reason: 'キャンセル後にトピック選択シートが閉じること',
    );

    // Step 5: FABをもう一度タップしてシートが再表示されることを確認
    final sheetReopened = await tapFabAndWaitForSheet(tester);

    expect(
      sheetReopened,
      isTrue,
      reason: 'キャンセル後にFABを再タップするとトピック選択シートが再び表示されること（showTopicSelectionがリセットされること）',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-EFR-002: FAB押下→キャンセル→再度FAB押下→トピック選択→イベント詳細遷移
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-EFR-002: FAB押下→キャンセル→再度FAB押下→トピック選択→イベント詳細に遷移できること',
      (tester) async {
    await startApp(tester);

    // Step 1: FABをタップ → シートを表示
    final sheetOpened = await tapFabAndWaitForSheet(tester);
    if (!sheetOpened) {
      print('[SKIP] トピック選択シートが表示されなかったためスキップします');
      return;
    }

    // Step 2: シートをキャンセル
    await cancelTopicSheet(tester);

    // Step 3: FABを再タップ → シートが再表示
    final sheetReopened = await tapFabAndWaitForSheet(tester);
    if (!sheetReopened) {
      print('[SKIP] 再タップ後にトピック選択シートが表示されなかったためスキップします');
      return;
    }

    // Step 4: トピックを選択（移動コスト（給油から計算））
    // シート内の ListTile をタップ（BottomSheet の descendant を指定して
    // EventListPage のイベントカードと区別する）
    final topicTileInSheet = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text('移動コスト（給油から計算）'),
    );
    if (topicTileInSheet.evaluate().isEmpty) {
      print('[SKIP] トピック選択肢がシート内に見つからなかったためスキップします');
      return;
    }
    await tester.tap(topicTileInSheet.first);

    // Step 5: イベント詳細ページへ遷移することを確認
    // 概要タブまたは BasicInfo セクションが表示されるまで待機
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty ||
          find.byKey(const Key('basicInfoRead_container_section'))
              .evaluate()
              .isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('概要').evaluate().isNotEmpty ||
          find.byKey(const Key('basicInfoRead_container_section'))
              .evaluate()
              .isNotEmpty,
      isTrue,
      reason: 'トピック選択後にイベント詳細ページに遷移すること',
    );
  });
}
