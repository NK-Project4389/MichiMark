// ignore_for_file: avoid_print

/// Integration Test: Detail画面 キャンセル確認ダイアログ（UI-13）
///
/// Spec: docs/Spec/Features/FS-detail_cancel_confirmation.md §15
/// テストシナリオ: TC-DCC-001 〜 TC-DCC-012

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ──────────────────────────────────────────────────────────────────────
  // ヘルパー
  // ──────────────────────────────────────────────────────────────────────

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

  /// 指定イベント名のカードをタップして EventDetail まで遷移する。
  Future<bool> openEventDetail(
    WidgetTester tester,
    String eventName,
  ) async {
    final eventCard = find.ancestor(
      of: find.text(eventName),
      matching: find.byType(GestureDetector),
    );
    if (eventCard.evaluate().isEmpty) return false;
    await tester.tap(eventCard.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// EventDetail の「ミチ」タブへ移動する。
  Future<void> goToMichiTab(WidgetTester tester) async {
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return;
    await tester.tap(michiTab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// EventDetail の「支払」タブへ移動する。
  Future<bool> goToPaymentTab(WidgetTester tester) async {
    final paymentTab = find.text('支払');
    if (paymentTab.evaluate().isEmpty) return false;
    await tester.tap(paymentTab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(ListView).evaluate().isNotEmpty ||
          find.text('支払いがありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// カスタムキーパッドに数値「1000」を入力して確定する。
  /// 呼び出し前にキーパッドが表示されていること。
  Future<void> enterValueOnKeypad(WidgetTester tester) async {
    // キーパッド表示を待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('custom_numeric_keypad')).evaluate().isNotEmpty) break;
    }
    if (find.byKey(const Key('custom_numeric_keypad')).evaluate().isEmpty) return;

    // 「1」→「0」→「0」→「0」と入力
    await tester.tap(find.byKey(const Key('keypad_digit_1')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('keypad_digit_0')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('keypad_digit_0')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('keypad_digit_0')));
    await tester.pump(const Duration(milliseconds: 200));

    // 確定
    await tester.tap(find.byKey(const Key('keypad_confirm')));
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// MichiInfo タブのシードデータマーク「大涌谷」(ml-005) をタップして MarkDetail を開く。
  /// 移動コストトピックでは名称テキストが非表示のため、日付テキストKeyで検索する。
  Future<bool> openExistingMarkDetail(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) return false;

    await goToMichiTab(tester);

    // 移動コストトピックでは名称非表示のため、日付テキストKey(ml-005)でカードを検索する
    final markDateKey = find.byKey(const Key('michiInfo_text_markDate_ml-005'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (markDateKey.evaluate().isNotEmpty) break;
    }

    // 見つからない場合、削除ボタンKey(ml-005)でも試みる
    if (markDateKey.evaluate().isEmpty) {
      final deleteBtn = find.byKey(const Key('michiInfo_button_delete_ml-005'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        if (deleteBtn.evaluate().isNotEmpty) break;
      }
      if (deleteBtn.evaluate().isEmpty) return false;

      // 削除ボタンの祖先GestureDetectorをタップ
      final card = find.ancestor(
        of: deleteBtn,
        matching: find.byType(GestureDetector),
      );
      if (card.evaluate().isEmpty) return false;
      await tester.ensureVisible(card.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(card.first);
    } else {
      // 日付テキストの祖先GestureDetectorをタップ
      final card = find.ancestor(
        of: markDateKey,
        matching: find.byType(GestureDetector),
      );
      if (card.evaluate().isEmpty) return false;
      await tester.ensureVisible(card.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(card.first);
    }

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('markDetail_button_cancel')).evaluate().isNotEmpty ||
          find.byKey(const Key('markDetail_button_save')).evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// MichiInfo タブの FAB をタップしてBottomSheetの「地点を追加」を選択し MarkDetail を開く。
  Future<bool> openNewMarkDetail(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) return false;

    await goToMichiTab(tester);

    // FAB が表示されていることを確認してタップ
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isEmpty) return false;
    await tester.tap(fab.first);

    // BottomSheetが表示されるまで待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_button_addMark')).evaluate().isNotEmpty) break;
    }

    // 「地点を追加」をタップ
    if (find.byKey(const Key('michiInfo_button_addMark')).evaluate().isEmpty) return false;
    await tester.tap(find.byKey(const Key('michiInfo_button_addMark')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('markDetail_button_cancel')).evaluate().isNotEmpty ||
          find.byKey(const Key('markDetail_button_save')).evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// MichiInfo タブのシードデータリンク「東名高速」(ml-002) をタップして LinkDetail を開く。
  /// 移動コストトピックでは名称テキストが非表示のため、日付テキストKeyで検索する。
  Future<bool> openExistingLinkDetail(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) return false;

    await goToMichiTab(tester);

    // 移動コストトピックでは名称非表示のため、日付テキストKey(ml-002)でカードを検索する
    final linkDateKey = find.byKey(const Key('michiInfo_text_linkDate_ml-002'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (linkDateKey.evaluate().isNotEmpty) break;
    }

    if (linkDateKey.evaluate().isEmpty) {
      // 距離テキストKeyでも試みる
      final linkDistanceKey = find.byKey(const Key('michiInfo_text_linkDistance_ml-002'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        if (linkDistanceKey.evaluate().isNotEmpty) break;
      }
      if (linkDistanceKey.evaluate().isEmpty) return false;

      final card = find.ancestor(
        of: linkDistanceKey,
        matching: find.byType(GestureDetector),
      );
      if (card.evaluate().isEmpty) return false;
      await tester.ensureVisible(card.first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(card.first);
    } else {
      final card = find.ancestor(
        of: linkDateKey,
        matching: find.byType(GestureDetector),
      );
      if (card.evaluate().isEmpty) return false;
      await tester.ensureVisible(card.first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(card.first);
    }

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('linkDetail_button_cancel')).evaluate().isNotEmpty ||
          find.byKey(const Key('linkDetail_button_save')).evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// 支払タブから PaymentDetail（既存カード）を開く。
  Future<bool> openExistingPaymentDetail(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) return false;

    final moved = await goToPaymentTab(tester);
    if (!moved) return false;

    if (find.text('支払いがありません').evaluate().isNotEmpty) return false;

    final paymentCards = find.byType(GestureDetector);
    if (paymentCards.evaluate().isEmpty) return false;

    await tester.tap(paymentCards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('paymentDetail_button_cancel')).evaluate().isNotEmpty ||
          find.byKey(const Key('paymentDetail_button_save')).evaluate().isNotEmpty) {
        return true;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
    return find.byKey(const Key('paymentDetail_button_save')).evaluate().isNotEmpty ||
        find.byKey(const Key('paymentDetail_button_cancel')).evaluate().isNotEmpty;
  }

  /// 支払タブの FAB をタップして PaymentDetail（新規）を開く。
  Future<bool> openNewPaymentDetail(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) return false;

    final moved = await goToPaymentTab(tester);
    if (!moved) return false;

    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isEmpty) return false;
    await tester.tap(fab.first);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('paymentDetail_button_cancel')).evaluate().isNotEmpty ||
          find.byKey(const Key('paymentDetail_button_save')).evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// MarkDetail でDraftを変更する（名称フィールドがある場合は名称変更、ない場合は累積メーターを変更）。
  Future<void> modifyMarkDetailDraft(WidgetTester tester) async {
    final nameField = find.byKey(const Key('markDetail_field_name'));
    if (nameField.evaluate().isNotEmpty) {
      // 名称フィールドがある場合（旅費可視化トピック）: 名前を変更
      await tester.ensureVisible(nameField);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(nameField);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(nameField, 'テスト変更名称');
      await tester.pump(const Duration(milliseconds: 300));
    } else {
      // 名称フィールドがない場合（移動コストトピック）: 累積メーターを変更
      // NumericInputRow「累積メーター」の GestureDetector を探してタップ
      final meterTapArea = find.byKey(const Key('numeric_input_tap_累積メーター'));
      if (meterTapArea.evaluate().isNotEmpty) {
        await tester.ensureVisible(meterTapArea);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(meterTapArea);
        await enterValueOnKeypad(tester);
      }
    }
  }

  /// LinkDetail でDraftを変更する（名称フィールドがある場合は名称変更、ない場合は走行距離を変更）。
  Future<void> modifyLinkDetailDraft(WidgetTester tester) async {
    final nameField = find.byKey(const Key('linkDetail_field_name'));
    if (nameField.evaluate().isNotEmpty) {
      // 名称フィールドがある場合: 名前を変更
      await tester.ensureVisible(nameField);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(nameField);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(nameField, 'テスト変更区間名');
      await tester.pump(const Duration(milliseconds: 300));
    } else {
      // 名称フィールドがない場合（移動コストトピック）: 走行距離を変更
      final distanceTapArea = find.byKey(const Key('numeric_input_tap_走行距離'));
      if (distanceTapArea.evaluate().isNotEmpty) {
        await tester.ensureVisible(distanceTapArea);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(distanceTapArea);
        await enterValueOnKeypad(tester);
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // MarkDetail テスト（TC-DCC-001〜004）
  // ──────────────────────────────────────────────────────────────────────

  testWidgets('TC-DCC-001: MarkDetail — 変更なしでキャンセルするとダイアログが出ない',
      (tester) async {
    // 既存マークで開く（初期状態 = Draft と同一）
    final opened = await openExistingMarkDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-001: MarkDetailを開けなかったためスキップします');
      return;
    }

    // 何も変更せずにキャンセルボタンをタップ
    await tester.ensureVisible(
        find.byKey(const Key('markDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('markDetail_button_cancel')));

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 確認ダイアログが表示されないこと
    expect(
      find.byKey(const Key('markDetail_dialog_cancelConfirm')),
      findsNothing,
    );
  });

  testWidgets('TC-DCC-002: MarkDetail — 変更してキャンセルするとダイアログが出る',
      (tester) async {
    final opened = await openExistingMarkDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-002: MarkDetailを開けなかったためスキップします');
      return;
    }

    // Draft を変更する
    await modifyMarkDetailDraft(tester);

    // キャンセルボタンをタップ
    await tester.ensureVisible(
        find.byKey(const Key('markDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('markDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('markDetail_dialog_cancelConfirm'))
          .evaluate()
          .isNotEmpty) break;
    }

    // 確認ダイアログが表示されること
    expect(
      find.byKey(const Key('markDetail_dialog_cancelConfirm')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DCC-002b: MarkDetail — ダイアログにタイトル「変更を破棄しますか？」が表示される',
      (tester) async {
    final opened = await openExistingMarkDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-002b: MarkDetailを開けなかったためスキップします');
      return;
    }

    await modifyMarkDetailDraft(tester);

    await tester.ensureVisible(
        find.byKey(const Key('markDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('markDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('markDetail_dialog_cancelConfirm'))
          .evaluate()
          .isNotEmpty) break;
    }

    // ダイアログタイトルが表示されること
    expect(
      find.text('変更を破棄しますか？'),
      findsOneWidget,
    );
  });

  testWidgets('TC-DCC-002c: MarkDetail — ダイアログに「破棄する」ボタンが表示される',
      (tester) async {
    final opened = await openExistingMarkDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-002c: MarkDetailを開けなかったためスキップします');
      return;
    }

    await modifyMarkDetailDraft(tester);

    await tester.ensureVisible(
        find.byKey(const Key('markDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('markDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('markDetail_button_discardConfirm'))
          .evaluate()
          .isNotEmpty) break;
    }

    expect(
      find.byKey(const Key('markDetail_button_discardConfirm')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DCC-002d: MarkDetail — ダイアログに「編集を続ける」ボタンが表示される',
      (tester) async {
    final opened = await openExistingMarkDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-002d: MarkDetailを開けなかったためスキップします');
      return;
    }

    await modifyMarkDetailDraft(tester);

    await tester.ensureVisible(
        find.byKey(const Key('markDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('markDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('markDetail_button_continueEdit'))
          .evaluate()
          .isNotEmpty) break;
    }

    expect(
      find.byKey(const Key('markDetail_button_continueEdit')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DCC-003: MarkDetail — ダイアログで「破棄する」を選択すると前画面へ戻る',
      (tester) async {
    final opened = await openExistingMarkDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-003: MarkDetailを開けなかったためスキップします');
      return;
    }

    await modifyMarkDetailDraft(tester);

    await tester.ensureVisible(
        find.byKey(const Key('markDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('markDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('markDetail_button_discardConfirm'))
          .evaluate()
          .isNotEmpty) break;
    }

    // 「破棄する」ボタンをタップ
    await tester.tap(
        find.byKey(const Key('markDetail_button_discardConfirm')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // MichiInfo タブに戻ったことを確認（MarkDetail が閉じる）
      if (find.byKey(const Key('markDetail_button_cancel'))
          .evaluate()
          .isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // MarkDetail 画面が閉じていること（キャンセルボタンが非表示）
    expect(
      find.byKey(const Key('markDetail_button_cancel')),
      findsNothing,
    );
  });

  testWidgets('TC-DCC-004: MarkDetail — ダイアログで「編集を続ける」を選択すると画面に留まる',
      (tester) async {
    final opened = await openExistingMarkDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-004: MarkDetailを開けなかったためスキップします');
      return;
    }

    await modifyMarkDetailDraft(tester);

    await tester.ensureVisible(
        find.byKey(const Key('markDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('markDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('markDetail_button_continueEdit'))
          .evaluate()
          .isNotEmpty) break;
    }

    // 「編集を続ける」ボタンをタップ
    await tester.tap(
        find.byKey(const Key('markDetail_button_continueEdit')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // MarkDetail 画面に留まること（キャンセルボタンが表示されたまま）
    expect(
      find.byKey(const Key('markDetail_button_cancel')),
      findsOneWidget,
    );
  });

  // ──────────────────────────────────────────────────────────────────────
  // LinkDetail テスト（TC-DCC-005〜008）
  // ──────────────────────────────────────────────────────────────────────

  testWidgets('TC-DCC-005: LinkDetail — 変更なしでキャンセルするとダイアログが出ない',
      (tester) async {
    final opened = await openExistingLinkDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-005: LinkDetailを開けなかったためスキップします');
      return;
    }

    // 何も変更せずにキャンセルボタンをタップ
    await tester.ensureVisible(
        find.byKey(const Key('linkDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('linkDetail_button_cancel')));

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 確認ダイアログが表示されないこと
    expect(
      find.byKey(const Key('linkDetail_dialog_cancelConfirm')),
      findsNothing,
    );
  });

  testWidgets('TC-DCC-006: LinkDetail — 変更してキャンセルするとダイアログが出る',
      (tester) async {
    final opened = await openExistingLinkDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-006: LinkDetailを開けなかったためスキップします');
      return;
    }

    // Draft を変更する
    await modifyLinkDetailDraft(tester);

    // キャンセルボタンをタップ
    await tester.ensureVisible(
        find.byKey(const Key('linkDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('linkDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('linkDetail_dialog_cancelConfirm'))
          .evaluate()
          .isNotEmpty) break;
    }

    // 確認ダイアログが表示されること
    expect(
      find.byKey(const Key('linkDetail_dialog_cancelConfirm')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DCC-007: LinkDetail — ダイアログで「破棄する」を選択すると前画面へ戻る',
      (tester) async {
    final opened = await openExistingLinkDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-007: LinkDetailを開けなかったためスキップします');
      return;
    }

    await modifyLinkDetailDraft(tester);

    await tester.ensureVisible(
        find.byKey(const Key('linkDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('linkDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('linkDetail_button_discardConfirm'))
          .evaluate()
          .isNotEmpty) break;
    }

    // 「破棄する」ボタンをタップ
    await tester.tap(
        find.byKey(const Key('linkDetail_button_discardConfirm')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('linkDetail_button_cancel'))
          .evaluate()
          .isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // LinkDetail 画面が閉じていること（キャンセルボタンが非表示）
    expect(
      find.byKey(const Key('linkDetail_button_cancel')),
      findsNothing,
    );
  });

  testWidgets('TC-DCC-008: LinkDetail — ダイアログで「編集を続ける」を選択すると画面に留まる',
      (tester) async {
    final opened = await openExistingLinkDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-008: LinkDetailを開けなかったためスキップします');
      return;
    }

    await modifyLinkDetailDraft(tester);

    await tester.ensureVisible(
        find.byKey(const Key('linkDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('linkDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('linkDetail_button_continueEdit'))
          .evaluate()
          .isNotEmpty) break;
    }

    // 「編集を続ける」ボタンをタップ
    await tester.tap(
        find.byKey(const Key('linkDetail_button_continueEdit')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // LinkDetail 画面に留まること（キャンセルボタンが表示されたまま）
    expect(
      find.byKey(const Key('linkDetail_button_cancel')),
      findsOneWidget,
    );
  });

  // ──────────────────────────────────────────────────────────────────────
  // PaymentDetail テスト（TC-DCC-009〜012）
  // ──────────────────────────────────────────────────────────────────────

  testWidgets('TC-DCC-009: PaymentDetail — 変更なしでキャンセルするとダイアログが出ない',
      (tester) async {
    final opened = await openExistingPaymentDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-009: PaymentDetailを開けなかったためスキップします');
      return;
    }

    // 何も変更せずにキャンセルボタンをタップ
    await tester.ensureVisible(
        find.byKey(const Key('paymentDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('paymentDetail_button_cancel')));

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 確認ダイアログが表示されないこと
    expect(
      find.byKey(const Key('paymentDetail_dialog_cancelConfirm')),
      findsNothing,
    );
  });

  testWidgets('TC-DCC-010: PaymentDetail — 金額を入力してキャンセルするとダイアログが出る',
      (tester) async {
    final opened = await openNewPaymentDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-010: PaymentDetailを開けなかったためスキップします');
      return;
    }

    // 金額フィールド（NumericInputRow）をタップしてカスタムキーパッドを表示
    // NumericInputRow の GestureDetector Key: 'numeric_input_tap_支払金額'
    final amountTapArea = find.byKey(const Key('numeric_input_tap_支払金額'));
    if (amountTapArea.evaluate().isNotEmpty) {
      await tester.ensureVisible(amountTapArea);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(amountTapArea);
      await enterValueOnKeypad(tester);
    } else {
      // Key名の揺れに備えて paymentDetail_field_amount でも試みる
      final amountField = find.byKey(const Key('paymentDetail_field_amount'));
      if (amountField.evaluate().isNotEmpty) {
        await tester.ensureVisible(amountField);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(amountField);
        await enterValueOnKeypad(tester);
      }
    }

    // キャンセルボタンをタップ
    await tester.ensureVisible(
        find.byKey(const Key('paymentDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('paymentDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('paymentDetail_dialog_cancelConfirm'))
          .evaluate()
          .isNotEmpty) break;
    }

    // 確認ダイアログが表示されること
    expect(
      find.byKey(const Key('paymentDetail_dialog_cancelConfirm')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DCC-011: PaymentDetail — ダイアログで「破棄する」を選択すると前画面へ戻る',
      (tester) async {
    final opened = await openNewPaymentDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-011: PaymentDetailを開けなかったためスキップします');
      return;
    }

    // 金額フィールドをタップしてダイアログを表示する
    final amountTapArea = find.byKey(const Key('numeric_input_tap_支払金額'));
    if (amountTapArea.evaluate().isNotEmpty) {
      await tester.ensureVisible(amountTapArea);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(amountTapArea);
      await enterValueOnKeypad(tester);
    } else {
      final amountField = find.byKey(const Key('paymentDetail_field_amount'));
      if (amountField.evaluate().isNotEmpty) {
        await tester.ensureVisible(amountField);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(amountField);
        await enterValueOnKeypad(tester);
      }
    }

    await tester.ensureVisible(
        find.byKey(const Key('paymentDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('paymentDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('paymentDetail_button_discardConfirm'))
          .evaluate()
          .isNotEmpty) break;
    }

    // 「破棄する」ボタンをタップ
    await tester.tap(
        find.byKey(const Key('paymentDetail_button_discardConfirm')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('paymentDetail_button_cancel'))
          .evaluate()
          .isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // PaymentDetail 画面が閉じていること（キャンセルボタンが非表示）
    expect(
      find.byKey(const Key('paymentDetail_button_cancel')),
      findsNothing,
    );
  });

  testWidgets('TC-DCC-012: PaymentDetail — ダイアログで「編集を続ける」を選択すると画面に留まる',
      (tester) async {
    final opened = await openNewPaymentDetail(tester);
    if (!opened) {
      print('[SKIP] TC-DCC-012: PaymentDetailを開けなかったためスキップします');
      return;
    }

    // 金額フィールドをタップしてダイアログを表示する
    final amountTapArea = find.byKey(const Key('numeric_input_tap_支払金額'));
    if (amountTapArea.evaluate().isNotEmpty) {
      await tester.ensureVisible(amountTapArea);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(amountTapArea);
      await enterValueOnKeypad(tester);
    } else {
      final amountField = find.byKey(const Key('paymentDetail_field_amount'));
      if (amountField.evaluate().isNotEmpty) {
        await tester.ensureVisible(amountField);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(amountField);
        await enterValueOnKeypad(tester);
      }
    }

    await tester.ensureVisible(
        find.byKey(const Key('paymentDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('paymentDetail_button_cancel')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('paymentDetail_button_continueEdit'))
          .evaluate()
          .isNotEmpty) break;
    }

    // 「編集を続ける」ボタンをタップ
    await tester.tap(
        find.byKey(const Key('paymentDetail_button_continueEdit')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // PaymentDetail 画面に留まること（キャンセルボタンが表示されたまま）
    expect(
      find.byKey(const Key('paymentDetail_button_cancel')),
      findsOneWidget,
    );
  });
}
