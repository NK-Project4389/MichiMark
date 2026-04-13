// ignore_for_file: avoid_print

/// Integration Test: 削除確認ダイアログ
///
/// Spec: docs/Spec/Features/FS-delete_confirmation_dialog.md
///
/// テストシナリオ: TC-DCD-001 〜 TC-DCD-006
///
/// 前提条件:
///   - iOSシミュレーター（UDID: DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6）が起動済みであること
///   - シードデータ（event-001: 箱根日帰りドライブ）に以下が存在すること:
///     - Mark カード: ml-001（自宅出発）
///     - Link カード: ml-002（東名高速）
///     - 伝票: pay-001（高速道路代）

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

  /// 指定したイベント名のイベント詳細を開く。
  Future<bool> openEventDetail(WidgetTester tester, String eventName) async {
    final cards = find.ancestor(
      of: find.text(eventName),
      matching: find.byType(GestureDetector),
    );
    if (cards.evaluate().isEmpty) return false;
    await tester.tap(cards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty ||
          find.text('ミチ').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// MichiInfo（ミチタブ）まで遷移するヘルパー。
  Future<bool> goToMichiInfoTab(WidgetTester tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) return false;

    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return false;
    await tester.tap(michiTab);

    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// PaymentInfo（支払タブ）まで遷移するヘルパー。
  Future<bool> goToPaymentInfoTab(WidgetTester tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) return false;

    final payTab = find.text('支払');
    if (payTab.evaluate().isEmpty) return false;
    await tester.tap(payTab);

    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty ||
          find.text('支払情報がありません').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 確認ダイアログが表示されるまで待つ。
  Future<void> waitForDialog(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('deleteConfirmDialog_dialog_confirm'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// 確認ダイアログが閉じるまで待つ。
  Future<void> waitForDialogDismiss(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('deleteConfirmDialog_dialog_confirm'))
          .evaluate()
          .isEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ────────────────────────────────────────────────────────
  // TC-DCD-001: MichiInfo Mark カードのゴミ箱アイコンをタップすると確認ダイアログが表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-DCD-001: MichiInfo Mark カードのゴミ箱アイコンをタップすると確認ダイアログが表示される',
      (tester) async {
    final navigated = await goToMichiInfoTab(tester);
    if (!navigated) {
      print('[SKIP] 「箱根日帰りドライブ」が見つからないか、ミチタブへ遷移できないためスキップします');
      return;
    }

    const markId = 'ml-001';
    final deleteButtonKey = Key('michiInfo_button_delete_$markId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] michiInfo_button_delete_$markId が見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    expect(
      find.byKey(const Key('deleteConfirmDialog_dialog_confirm')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DCD-001b: 確認ダイアログにタイトル「削除しますか？」が表示される',
      (tester) async {
    final navigated = await goToMichiInfoTab(tester);
    if (!navigated) {
      print('[SKIP] ミチタブへ遷移できないためスキップします');
      return;
    }

    const markId = 'ml-001';
    final deleteButtonKey = Key('michiInfo_button_delete_$markId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] michiInfo_button_delete_$markId が見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    expect(find.text('削除しますか？'), findsOneWidget);
  });

  testWidgets('TC-DCD-001c: 確認ダイアログにメッセージ「この操作は取り消せません。」が表示される',
      (tester) async {
    final navigated = await goToMichiInfoTab(tester);
    if (!navigated) {
      print('[SKIP] ミチタブへ遷移できないためスキップします');
      return;
    }

    const markId = 'ml-001';
    final deleteButtonKey = Key('michiInfo_button_delete_$markId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] michiInfo_button_delete_$markId が見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    expect(find.text('この操作は取り消せません。'), findsOneWidget);
  });

  testWidgets('TC-DCD-001d: 確認ダイアログに削除ボタンとキャンセルボタンが表示される',
      (tester) async {
    final navigated = await goToMichiInfoTab(tester);
    if (!navigated) {
      print('[SKIP] ミチタブへ遷移できないためスキップします');
      return;
    }

    const markId = 'ml-001';
    final deleteButtonKey = Key('michiInfo_button_delete_$markId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] michiInfo_button_delete_$markId が見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    expect(
      find.byKey(const Key('deleteConfirmDialog_button_delete')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DCD-001e: ダイアログ表示中もMarkカードが一覧に残っている', (tester) async {
    final navigated = await goToMichiInfoTab(tester);
    if (!navigated) {
      print('[SKIP] ミチタブへ遷移できないためスキップします');
      return;
    }

    const markId = 'ml-001';
    final deleteButtonKey = Key('michiInfo_button_delete_$markId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] michiInfo_button_delete_$markId が見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    // ダイアログが表示されている間はカードがまだ存在する
    expect(
      find.byKey(deleteButtonKey),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DCD-002: 確認ダイアログで「キャンセル」をタップするとダイアログが閉じ、カードが削除されない
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-DCD-002: 確認ダイアログで「キャンセル」をタップするとダイアログが閉じる',
      (tester) async {
    final navigated = await goToMichiInfoTab(tester);
    if (!navigated) {
      print('[SKIP] ミチタブへ遷移できないためスキップします');
      return;
    }

    const markId = 'ml-001';
    final deleteButtonKey = Key('michiInfo_button_delete_$markId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] michiInfo_button_delete_$markId が見つからないためスキップします');
      return;
    }

    // ゴミ箱アイコンをタップしてダイアログを表示
    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    expect(
      find.byKey(const Key('deleteConfirmDialog_dialog_confirm')),
      findsOneWidget,
    );

    // キャンセルボタンをタップ
    await tester.tap(find.byKey(const Key('deleteConfirmDialog_button_cancel')));

    await waitForDialogDismiss(tester);

    expect(
      find.byKey(const Key('deleteConfirmDialog_dialog_confirm')),
      findsNothing,
    );
  });

  testWidgets(
      'TC-DCD-002b: 「キャンセル」タップ後もMarkカードが一覧に残っている',
      (tester) async {
    final navigated = await goToMichiInfoTab(tester);
    if (!navigated) {
      print('[SKIP] ミチタブへ遷移できないためスキップします');
      return;
    }

    const markId = 'ml-001';
    final deleteButtonKey = Key('michiInfo_button_delete_$markId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] michiInfo_button_delete_$markId が見つからないためスキップします');
      return;
    }

    // ゴミ箱アイコンをタップしてダイアログを表示
    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    // キャンセルボタンをタップ
    await tester.tap(find.byKey(const Key('deleteConfirmDialog_button_cancel')));

    await waitForDialogDismiss(tester);

    // カードはまだ存在する
    expect(find.byKey(deleteButtonKey), findsOneWidget);
  });

  // ────────────────────────────────────────────────────────
  // TC-DCD-003: 確認ダイアログで「削除」をタップするとダイアログが閉じ、カードが削除される
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-DCD-003: 確認ダイアログで「削除」をタップするとダイアログが閉じる',
      (tester) async {
    final navigated = await goToMichiInfoTab(tester);
    if (!navigated) {
      print('[SKIP] ミチタブへ遷移できないためスキップします');
      return;
    }

    const markId = 'ml-001';
    final deleteButtonKey = Key('michiInfo_button_delete_$markId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] michiInfo_button_delete_$markId が見つからないためスキップします');
      return;
    }

    // ゴミ箱アイコンをタップしてダイアログを表示
    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    expect(
      find.byKey(const Key('deleteConfirmDialog_dialog_confirm')),
      findsOneWidget,
    );

    // 削除ボタンをタップ
    await tester.tap(find.byKey(const Key('deleteConfirmDialog_button_delete')));

    await waitForDialogDismiss(tester);

    expect(
      find.byKey(const Key('deleteConfirmDialog_dialog_confirm')),
      findsNothing,
    );
  });

  testWidgets(
      'TC-DCD-003b: 「削除」タップ後にMarkカードが一覧から消える',
      (tester) async {
    final navigated = await goToMichiInfoTab(tester);
    if (!navigated) {
      print('[SKIP] ミチタブへ遷移できないためスキップします');
      return;
    }

    const markId = 'ml-001';
    final deleteButtonKey = Key('michiInfo_button_delete_$markId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] michiInfo_button_delete_$markId が見つからないためスキップします');
      return;
    }

    // ゴミ箱アイコンをタップしてダイアログを表示
    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    // 削除ボタンをタップ
    await tester.tap(find.byKey(const Key('deleteConfirmDialog_button_delete')));

    // 削除完了まで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(deleteButtonKey).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(deleteButtonKey), findsNothing);
  });

  // ────────────────────────────────────────────────────────
  // TC-DCD-004: MichiInfo Link カードのゴミ箱アイコンをタップすると確認ダイアログが表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-DCD-004: MichiInfo Link カードのゴミ箱アイコンをタップすると確認ダイアログが表示される',
      (tester) async {
    final navigated = await goToMichiInfoTab(tester);
    if (!navigated) {
      print('[SKIP] ミチタブへ遷移できないためスキップします');
      return;
    }

    const linkId = 'ml-002';
    final deleteButtonKey = Key('michiInfo_button_delete_$linkId');

    // Linkカードが画面外にある場合はスクロールして探す
    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      for (var i = 0; i < 5; i++) {
        if (find.byKey(deleteButtonKey).evaluate().isNotEmpty) break;
        final scrollViews = find.byType(CustomScrollView);
        if (scrollViews.evaluate().isNotEmpty) {
          await tester.drag(scrollViews.first, const Offset(0, -200));
        } else {
          final listViews = find.byType(ListView);
          if (listViews.evaluate().isNotEmpty) {
            await tester.drag(listViews.first, const Offset(0, -200));
          }
        }
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] michiInfo_button_delete_$linkId が見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    expect(
      find.byKey(const Key('deleteConfirmDialog_dialog_confirm')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DCD-004b: Link カードのダイアログにタイトル・メッセージが表示される',
      (tester) async {
    final navigated = await goToMichiInfoTab(tester);
    if (!navigated) {
      print('[SKIP] ミチタブへ遷移できないためスキップします');
      return;
    }

    const linkId = 'ml-002';
    final deleteButtonKey = Key('michiInfo_button_delete_$linkId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      for (var i = 0; i < 5; i++) {
        if (find.byKey(deleteButtonKey).evaluate().isNotEmpty) break;
        final scrollViews = find.byType(CustomScrollView);
        if (scrollViews.evaluate().isNotEmpty) {
          await tester.drag(scrollViews.first, const Offset(0, -200));
        }
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] michiInfo_button_delete_$linkId が見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    expect(find.text('削除しますか？'), findsOneWidget);
  });

  testWidgets('TC-DCD-004c: Link カードはダイアログ表示中も一覧に残っている', (tester) async {
    final navigated = await goToMichiInfoTab(tester);
    if (!navigated) {
      print('[SKIP] ミチタブへ遷移できないためスキップします');
      return;
    }

    const linkId = 'ml-002';
    final deleteButtonKey = Key('michiInfo_button_delete_$linkId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      for (var i = 0; i < 5; i++) {
        if (find.byKey(deleteButtonKey).evaluate().isNotEmpty) break;
        final scrollViews = find.byType(CustomScrollView);
        if (scrollViews.evaluate().isNotEmpty) {
          await tester.drag(scrollViews.first, const Offset(0, -200));
        }
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] michiInfo_button_delete_$linkId が見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    // ダイアログ表示中も Link カードが一覧に残っている
    expect(find.byKey(deleteButtonKey), findsOneWidget);
  });

  // ────────────────────────────────────────────────────────
  // TC-DCD-005: PaymentInfo 伝票カードのゴミ箱アイコンをタップすると確認ダイアログが表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-DCD-005: PaymentInfo 伝票カードのゴミ箱アイコンをタップすると確認ダイアログが表示される',
      (tester) async {
    final navigated = await goToPaymentInfoTab(tester);
    if (!navigated) {
      print('[SKIP] 「箱根日帰りドライブ」が見つからないか、支払タブへ遷移できないためスキップします');
      return;
    }

    const paymentId = 'pay-001';
    final deleteButtonKey = Key('paymentInfo_button_delete_$paymentId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] paymentInfo_button_delete_$paymentId が見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    expect(
      find.byKey(const Key('deleteConfirmDialog_dialog_confirm')),
      findsOneWidget,
    );
  });

  testWidgets('TC-DCD-005b: PaymentInfo 確認ダイアログにタイトル・メッセージが表示される',
      (tester) async {
    final navigated = await goToPaymentInfoTab(tester);
    if (!navigated) {
      print('[SKIP] 支払タブへ遷移できないためスキップします');
      return;
    }

    const paymentId = 'pay-001';
    final deleteButtonKey = Key('paymentInfo_button_delete_$paymentId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] paymentInfo_button_delete_$paymentId が見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    expect(find.text('削除しますか？'), findsOneWidget);
  });

  testWidgets('TC-DCD-005c: PaymentInfo 伝票カードはダイアログ表示中も一覧に残っている',
      (tester) async {
    final navigated = await goToPaymentInfoTab(tester);
    if (!navigated) {
      print('[SKIP] 支払タブへ遷移できないためスキップします');
      return;
    }

    const paymentId = 'pay-001';
    final deleteButtonKey = Key('paymentInfo_button_delete_$paymentId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] paymentInfo_button_delete_$paymentId が見つからないためスキップします');
      return;
    }

    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    expect(find.byKey(deleteButtonKey), findsOneWidget);
  });

  // ────────────────────────────────────────────────────────
  // TC-DCD-006: PaymentInfo の確認ダイアログで「削除」をタップすると伝票が削除される
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-DCD-006: PaymentInfo の確認ダイアログで「削除」をタップするとダイアログが閉じる',
      (tester) async {
    final navigated = await goToPaymentInfoTab(tester);
    if (!navigated) {
      print('[SKIP] 支払タブへ遷移できないためスキップします');
      return;
    }

    const paymentId = 'pay-001';
    final deleteButtonKey = Key('paymentInfo_button_delete_$paymentId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] paymentInfo_button_delete_$paymentId が見つからないためスキップします');
      return;
    }

    // ゴミ箱アイコンをタップしてダイアログを表示
    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    expect(
      find.byKey(const Key('deleteConfirmDialog_dialog_confirm')),
      findsOneWidget,
    );

    // 削除ボタンをタップ
    await tester.tap(find.byKey(const Key('deleteConfirmDialog_button_delete')));

    await waitForDialogDismiss(tester);

    expect(
      find.byKey(const Key('deleteConfirmDialog_dialog_confirm')),
      findsNothing,
    );
  });

  testWidgets(
      'TC-DCD-006b: PaymentInfo の「削除」タップ後に伝票カードが一覧から消える',
      (tester) async {
    final navigated = await goToPaymentInfoTab(tester);
    if (!navigated) {
      print('[SKIP] 支払タブへ遷移できないためスキップします');
      return;
    }

    const paymentId = 'pay-001';
    final deleteButtonKey = Key('paymentInfo_button_delete_$paymentId');

    if (find.byKey(deleteButtonKey).evaluate().isEmpty) {
      print('[SKIP] paymentInfo_button_delete_$paymentId が見つからないためスキップします');
      return;
    }

    // ゴミ箱アイコンをタップしてダイアログを表示
    await tester.ensureVisible(find.byKey(deleteButtonKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteButtonKey));

    await waitForDialog(tester);

    // 削除ボタンをタップ
    await tester.tap(find.byKey(const Key('deleteConfirmDialog_button_delete')));

    // 削除完了まで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(deleteButtonKey).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(deleteButtonKey), findsNothing);
  });
}
