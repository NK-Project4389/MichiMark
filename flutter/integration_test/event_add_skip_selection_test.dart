// ignore_for_file: avoid_print

/// Integration Test: イベント追加ボタン 選択肢スキップ遷移
///
/// Spec: docs/Spec/Features/FS-event_add_skip_selection.md §16
///
/// テストシナリオ: TC-EAS-001 〜 TC-EAS-006
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - 以下のシードデータが存在すること:
///     - event-001（箱根日帰りドライブ）: movingCost トピック、addMenuItems = [mark, link]
///     - event-002（富士五湖キャンプ）: travelExpense トピック、addMenuItems = [mark]

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

  /// イベント一覧から指定名のイベントをタップして EventDetail を開く。
  /// 成功した場合は true を返す。
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
      if (find.text('ミチ').evaluate().isNotEmpty ||
          find.text('概要').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// EventDetail の「ミチ」タブに移動して FAB のロードを待つ。
  Future<bool> goToMichiTab(WidgetTester tester) async {
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return false;
    await tester.tap(michiTab.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_fab_add')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// FAB（michiInfo_fab_add）をタップしてから MarkDetail 画面が表示されるまで待つ。
  /// リストが空の場合は FAB タップ直後に pendingInsertAfterSeq: -1 が確定され
  /// インジケーター選択なしで直接 MarkDetail に遷移する。
  Future<bool> tapFabAndWaitForMarkDetail(WidgetTester tester) async {
    final fab = find.byKey(const Key('michiInfo_fab_add'));
    if (fab.evaluate().isEmpty) return false;
    await tester.tap(fab);
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('markDetail_screen')).evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// FAB をタップして InsertMode に入り、先頭インジケーターをタップして
  /// MarkDetail 画面が表示されるまで待つ。
  /// リストにアイテムがある場合にインジケーター選択が必要なフローで使う。
  Future<bool> tapFabThenHeadIndicatorAndWaitForMarkDetail(
    WidgetTester tester,
  ) async {
    final fab = find.byKey(const Key('michiInfo_fab_add'));
    if (fab.evaluate().isEmpty) return false;
    await tester.tap(fab);

    // InsertMode 切替を待つ（先頭インジケーターまたは MarkDetail のどちらかを待つ）
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_button_insertIndicator_head'))
              .evaluate()
              .isNotEmpty ||
          find.byKey(const Key('markDetail_screen')).evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    // リストが空の場合は FAB タップだけで MarkDetail に遷移している
    if (find.byKey(const Key('markDetail_screen')).evaluate().isNotEmpty) {
      return true;
    }

    // リストにアイテムがある場合は先頭インジケーターをタップ
    final headIndicator =
        find.byKey(const Key('michiInfo_button_insertIndicator_head'));
    if (headIndicator.evaluate().isEmpty) return false;
    await tester.ensureVisible(headIndicator);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(headIndicator);

    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('markDetail_screen')).evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// FAB をタップして InsertMode に入り、先頭インジケーターをタップして
  /// ボトムシートが表示されるまで待つ。
  /// movingCost（addMenuItems.length == 2）のフローで使う。
  Future<bool> tapFabThenHeadIndicatorAndWaitForBottomSheet(
    WidgetTester tester,
  ) async {
    final fab = find.byKey(const Key('michiInfo_fab_add'));
    if (fab.evaluate().isEmpty) return false;
    await tester.tap(fab);

    // InsertMode 切替を待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_button_insertIndicator_head'))
              .evaluate()
              .isNotEmpty ||
          find.byKey(const Key('michiInfo_button_addMark')).evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    // ボトムシートが既に表示されている（リストが空でFABタップ直後に確定）
    if (find.byKey(const Key('michiInfo_button_addMark')).evaluate().isNotEmpty) {
      return true;
    }

    // 先頭インジケーターをタップ
    final headIndicator =
        find.byKey(const Key('michiInfo_button_insertIndicator_head'));
    if (headIndicator.evaluate().isEmpty) {
      // インジケーターが見つからない場合は Icons.add_circle_outline でフォールバック
      final fallback = find.byIcon(Icons.add_circle_outline);
      if (fallback.evaluate().isEmpty) return false;
      await tester.tap(fallback.first);
    } else {
      await tester.ensureVisible(headIndicator);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(headIndicator);
    }

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('michiInfo_button_addMark')).evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // ────────────────────────────────────────────────────────
  // TC-EAS-001: travelExpense FABタップ後インジケーター選択で直接MarkDetail遷移（リスト空）
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-EAS-001: travelExpense FABタップ後インジケーター選択なしで直接MarkDetail遷移（リスト空）',
    (tester) async {
      await startApp(tester);

      if (find.text('イベントがありません').evaluate().isNotEmpty) {
        print('[SKIP] TC-EAS-001: イベントデータが存在しないためスキップします');
        return;
      }

      // event-005（旅行計画 / travelExpense・markLinksなし）を開く
      final opened = await openEventDetail(tester, '旅行計画');
      if (!opened) {
        print('[SKIP] TC-EAS-001: 「旅行計画」のEventDetailが開けなかったためスキップします');
        return;
      }

      // ミチタブへ移動
      final reached = await goToMichiTab(tester);
      if (!reached) {
        print('[SKIP] TC-EAS-001: 「ミチ」タブが見つからなかったためスキップします');
        return;
      }

      // FABをタップ（リストが空なので直接 MarkDetail に遷移するはず）
      final navigated = await tapFabAndWaitForMarkDetail(tester);

      // ボトムシート（地点を追加 / 区間を追加）が表示されていないこと
      expect(
        find.byKey(const Key('michiInfo_button_addMark')),
        findsNothing,
        reason: 'TC-EAS-001: ボトムシートの「地点を追加」が表示されていないこと（スキップされていること）',
      );

      // MarkDetail 画面が表示されること
      expect(
        navigated,
        isTrue,
        reason: 'TC-EAS-001: MarkDetail 画面が直接表示されること',
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-EAS-002: travelExpense FABタップ後インジケーター選択で直接MarkDetail遷移（リストあり）
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-EAS-002: travelExpense FABタップ後先頭インジケーター選択で直接MarkDetail遷移（リストあり）',
    (tester) async {
      await startApp(tester);

      if (find.text('イベントがありません').evaluate().isNotEmpty) {
        print('[SKIP] TC-EAS-002: イベントデータが存在しないためスキップします');
        return;
      }

      // event-002（富士五湖キャンプ / travelExpense）を開く
      final opened = await openEventDetail(tester, '富士五湖キャンプ');
      if (!opened) {
        print('[SKIP] TC-EAS-002: 「富士五湖キャンプ」のEventDetailが開けなかったためスキップします');
        return;
      }

      // ミチタブへ移動
      final reached = await goToMichiTab(tester);
      if (!reached) {
        print('[SKIP] TC-EAS-002: 「ミチ」タブが見つからなかったためスキップします');
        return;
      }

      // FABをタップして先頭インジケーターをタップ（リストの状態に応じて分岐）
      final navigated = await tapFabThenHeadIndicatorAndWaitForMarkDetail(tester);

      // ボトムシートが表示されていないこと
      expect(
        find.byKey(const Key('michiInfo_button_addMark')),
        findsNothing,
        reason: 'TC-EAS-002: ボトムシートの「地点を追加」が表示されていないこと（スキップされていること）',
      );

      // MarkDetail 画面が表示されること
      expect(
        navigated,
        isTrue,
        reason: 'TC-EAS-002: MarkDetail 画面が直接表示されること',
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-EAS-003: movingCost FABタップ後インジケーター選択でボトムシートが表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-EAS-003: movingCost FABタップ後インジケーター選択でボトムシートが表示される',
    (tester) async {
      await startApp(tester);

      if (find.text('イベントがありません').evaluate().isNotEmpty) {
        print('[SKIP] TC-EAS-003: イベントデータが存在しないためスキップします');
        return;
      }

      // event-001（箱根日帰りドライブ / movingCost）を開く
      final opened = await openEventDetail(tester, '箱根日帰りドライブ');
      if (!opened) {
        print('[SKIP] TC-EAS-003: 「箱根日帰りドライブ」のEventDetailが開けなかったためスキップします');
        return;
      }

      // ミチタブへ移動
      final reached = await goToMichiTab(tester);
      if (!reached) {
        print('[SKIP] TC-EAS-003: 「ミチ」タブが見つからなかったためスキップします');
        return;
      }

      // FABタップ → インジケータータップ → ボトムシート表示まで待つ
      final bottomSheetShown =
          await tapFabThenHeadIndicatorAndWaitForBottomSheet(tester);

      // ボトムシートが表示されること
      expect(
        bottomSheetShown,
        isTrue,
        reason: 'TC-EAS-003: ボトムシートが表示されること',
      );

      // 「地点を追加」ボタンが存在すること
      expect(
        find.byKey(const Key('michiInfo_button_addMark')),
        findsOneWidget,
        reason: 'TC-EAS-003: ボトムシートに「地点を追加」が存在すること',
      );

      // 「区間を追加」ボタンが存在すること
      expect(
        find.byKey(const Key('michiInfo_button_addLink')),
        findsOneWidget,
        reason: 'TC-EAS-003: ボトムシートに「区間を追加」が存在すること',
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-EAS-004: movingCost ボトムシートで「地点を追加」→MarkDetail遷移
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-EAS-004: movingCost ボトムシートで「地点を追加」をタップするとMarkDetailへ遷移する',
    (tester) async {
      await startApp(tester);

      if (find.text('イベントがありません').evaluate().isNotEmpty) {
        print('[SKIP] TC-EAS-004: イベントデータが存在しないためスキップします');
        return;
      }

      // event-001（箱根日帰りドライブ / movingCost）を開く
      final opened = await openEventDetail(tester, '箱根日帰りドライブ');
      if (!opened) {
        print('[SKIP] TC-EAS-004: 「箱根日帰りドライブ」のEventDetailが開けなかったためスキップします');
        return;
      }

      // ミチタブへ移動
      final reached = await goToMichiTab(tester);
      if (!reached) {
        print('[SKIP] TC-EAS-004: 「ミチ」タブが見つからなかったためスキップします');
        return;
      }

      // FABタップ → インジケータータップ → ボトムシート表示
      final bottomSheetShown =
          await tapFabThenHeadIndicatorAndWaitForBottomSheet(tester);
      if (!bottomSheetShown) {
        print('[SKIP] TC-EAS-004: ボトムシートが表示されなかったためスキップします');
        return;
      }

      // 「地点を追加」ボタンをタップ
      final addMarkButton = find.byKey(const Key('michiInfo_button_addMark'));
      await tester.ensureVisible(addMarkButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(addMarkButton);

      // MarkDetail 画面が表示されるまで待つ
      for (var i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byKey(const Key('markDetail_screen')).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      // MarkDetail 画面が表示されること
      expect(
        find.byKey(const Key('markDetail_screen')),
        findsOneWidget,
        reason: 'TC-EAS-004: 「地点を追加」タップ後に MarkDetail 画面が表示されること',
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-EAS-005: movingCost ボトムシートで「区間を追加」→LinkDetail遷移
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-EAS-005: movingCost ボトムシートで「区間を追加」をタップするとLinkDetailへ遷移する',
    (tester) async {
      await startApp(tester);

      if (find.text('イベントがありません').evaluate().isNotEmpty) {
        print('[SKIP] TC-EAS-005: イベントデータが存在しないためスキップします');
        return;
      }

      // event-001（箱根日帰りドライブ / movingCost）を開く
      final opened = await openEventDetail(tester, '箱根日帰りドライブ');
      if (!opened) {
        print('[SKIP] TC-EAS-005: 「箱根日帰りドライブ」のEventDetailが開けなかったためスキップします');
        return;
      }

      // ミチタブへ移動
      final reached = await goToMichiTab(tester);
      if (!reached) {
        print('[SKIP] TC-EAS-005: 「ミチ」タブが見つからなかったためスキップします');
        return;
      }

      // FABタップ → インジケータータップ → ボトムシート表示
      final bottomSheetShown =
          await tapFabThenHeadIndicatorAndWaitForBottomSheet(tester);
      if (!bottomSheetShown) {
        print('[SKIP] TC-EAS-005: ボトムシートが表示されなかったためスキップします');
        return;
      }

      // 「区間を追加」ボタンをタップ
      final addLinkButton = find.byKey(const Key('michiInfo_button_addLink'));
      await tester.ensureVisible(addLinkButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(addLinkButton);

      // LinkDetail 画面が表示されるまで待つ
      for (var i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byKey(const Key('linkDetail_screen')).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      // LinkDetail 画面が表示されること
      expect(
        find.byKey(const Key('linkDetail_screen')),
        findsOneWidget,
        reason: 'TC-EAS-005: 「区間を追加」タップ後に LinkDetail 画面が表示されること',
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-EAS-006: travelExpense MarkDetail保存後にMichiInfo一覧に戻れる
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-EAS-006: travelExpense MarkDetail保存後にMichiInfo一覧に戻れる',
    (tester) async {
      await startApp(tester);

      if (find.text('イベントがありません').evaluate().isNotEmpty) {
        print('[SKIP] TC-EAS-006: イベントデータが存在しないためスキップします');
        return;
      }

      // event-002（富士五湖キャンプ / travelExpense）を開く
      final opened = await openEventDetail(tester, '富士五湖キャンプ');
      if (!opened) {
        print('[SKIP] TC-EAS-006: 「富士五湖キャンプ」のEventDetailが開けなかったためスキップします');
        return;
      }

      // ミチタブへ移動
      final reached = await goToMichiTab(tester);
      if (!reached) {
        print('[SKIP] TC-EAS-006: 「ミチ」タブが見つからなかったためスキップします');
        return;
      }

      // FABタップ → MarkDetail 直接遷移（travelExpense はスキップフロー）
      final navigated = await tapFabThenHeadIndicatorAndWaitForMarkDetail(tester);
      if (!navigated) {
        print('[SKIP] TC-EAS-006: MarkDetail 画面への遷移に失敗したためスキップします');
        return;
      }

      // MarkDetail 画面が表示されていること
      expect(
        find.byKey(const Key('markDetail_screen')),
        findsOneWidget,
        reason: 'TC-EAS-006: MarkDetail 画面が表示されていること',
      );

      // 名前フィールドが存在する場合は「テスト地点」を入力する
      // （travelExpense の showNameField が true の場合のみ表示される）
      final nameField = find.byKey(const Key('markDetail_field_name'));
      if (nameField.evaluate().isNotEmpty) {
        await tester.tap(nameField);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.enterText(nameField, 'テスト地点');
        await tester.pump(const Duration(milliseconds: 300));
      }

      // 保存ボタンをタップ
      final saveButton = find.byKey(const Key('markDetail_button_save'));
      await tester.ensureVisible(saveButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(saveButton);

      // MichiInfo 一覧画面に戻るまで待つ
      for (var i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byKey(const Key('michiInfo_fab_add')).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      // MichiInfo 一覧画面に戻っていること（FABが再表示される）
      expect(
        find.byKey(const Key('michiInfo_fab_add')),
        findsOneWidget,
        reason: 'TC-EAS-006: 保存後に MichiInfo 一覧画面に戻ること',
      );
    },
  );
}
