// ignore_for_file: avoid_print

/// Integration Test: MarkDetail/LinkDetail/PaymentDetail UI改善（UI-5）
///
/// Feature Spec: docs/Spec/Features/FS-detail_screen_ui_improvement.md
/// テストシナリオ: TC-DSI-001〜015

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

  /// アプリを起動してEventListPageが表示されるまで待つ。
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

  /// 指定イベント名のカードをタップしてEventDetailまで遷移する。
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

  /// EventDetailのミチタブに移動する。
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

  /// MarkDetail画面を開く（既存Markカードをタップ）。
  /// 「箱根日帰りドライブ」の「大涌谷」カードを使用。
  Future<bool> openMarkDetail(WidgetTester tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) return false;

    await goToMichiTab(tester);

    // 「大涌谷」カードをタップ
    final markCard = find.text('大涌谷');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (markCard.evaluate().isNotEmpty) break;
    }
    if (markCard.evaluate().isEmpty) return false;

    await tester.ensureVisible(markCard);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(markCard);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('markDetail_button_save')).evaluate().isNotEmpty ||
          find.byKey(const Key('markDetail_appBar_title')).evaluate().isNotEmpty ||
          find.text('累積メーター').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// LinkDetail画面を開く（シードデータのLink名「東名高速」をタップ）。
  Future<bool> openLinkDetail(WidgetTester tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) return false;

    await goToMichiTab(tester);

    // シードデータのLink名「東名高速」をテキストで探す（michi_info_layout_test.dart TS-04 参考）
    final linkText = find.text('東名高速');
    if (linkText.evaluate().isEmpty) {
      // スクロールして探す
      final listView = find.byType(ListView);
      for (var i = 0; i < 5; i++) {
        if (find.text('東名高速').evaluate().isNotEmpty) break;
        if (listView.evaluate().isNotEmpty) {
          await tester.drag(listView.first, const Offset(0, -200));
          await tester.pump(const Duration(milliseconds: 300));
        }
      }
      if (find.text('東名高速').evaluate().isEmpty) return false;
    }

    await tester.ensureVisible(find.text('東名高速').first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('東名高速').first);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('linkDetail_appBar_title')).evaluate().isNotEmpty ||
          find.byKey(const Key('linkDetail_button_save')).evaluate().isNotEmpty) break;
    }

    return find.byKey(const Key('linkDetail_appBar_title')).evaluate().isNotEmpty ||
        find.byKey(const Key('linkDetail_button_save')).evaluate().isNotEmpty;
  }

  /// PaymentDetail画面を開く。
  Future<bool> openPaymentDetail(WidgetTester tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) return false;

    // 支払タブに移動
    final paymentTab = find.text('支払');
    if (paymentTab.evaluate().isEmpty) return false;
    await tester.tap(paymentTab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(ListView).evaluate().isNotEmpty ||
          find.text('支払いがありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    if (find.text('支払いがありません').evaluate().isNotEmpty) return false;

    // 支払いカードをタップ
    final paymentCards = find.byType(GestureDetector);
    if (paymentCards.evaluate().isEmpty) return false;

    await tester.tap(paymentCards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('paymentDetail_button_save')).evaluate().isNotEmpty ||
          find.byKey(const Key('paymentDetail_appBar_title')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return find.byKey(const Key('paymentDetail_button_save')).evaluate().isNotEmpty ||
        find.byKey(const Key('paymentDetail_appBar_title')).evaluate().isNotEmpty;
  }

  // ────────────────────────────────────────────────────────
  // TC-DSI-001: MarkDetail — 戻るボタンが表示されないこと
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-001: MarkDetail — AppBar左端に戻るボタン（markDetail_appBar_backButton）が存在しないこと',
      (tester) async {
    final opened = await openMarkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-001: MarkDetailを開けなかったためスキップします');
      return;
    }

    expect(
      find.byKey(const Key('markDetail_appBar_backButton')),
      findsNothing,
      reason: 'MarkDetail AppBarに戻るボタンが存在しないこと',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-002: LinkDetail — 戻るボタンが表示されないこと
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-002: LinkDetail — AppBar左端に戻るボタン（linkDetail_appBar_backButton）が存在しないこと',
      (tester) async {
    final opened = await openLinkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-002: LinkDetailを開けなかったためスキップします');
      return;
    }

    expect(
      find.byKey(const Key('linkDetail_appBar_backButton')),
      findsNothing,
      reason: 'LinkDetail AppBarに戻るボタンが存在しないこと',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-003: PaymentDetail — 戻るボタンが表示されないこと
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-003: PaymentDetail — AppBar左端に戻るボタン（paymentDetail_appBar_backButton）が存在しないこと',
      (tester) async {
    final opened = await openPaymentDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-003: PaymentDetailを開けなかったためスキップします');
      return;
    }

    expect(
      find.byKey(const Key('paymentDetail_appBar_backButton')),
      findsNothing,
      reason: 'PaymentDetail AppBarに戻るボタンが存在しないこと',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-004: MarkDetail — ヘッダタイトルが「地点詳細：(名称)」形式であること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-004: MarkDetail — AppBarタイトルが「地点詳細：大涌谷」形式で表示されること',
      (tester) async {
    final opened = await openMarkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-004: MarkDetailを開けなかったためスキップします');
      return;
    }

    final titleWidget = find.byKey(const Key('markDetail_appBar_title'));
    expect(
      titleWidget,
      findsOneWidget,
      reason: 'markDetail_appBar_title キーを持つウィジェットが存在すること',
    );

    // タイトルが「地点詳細：」プレフィックスを含む形式であること
    final titleText = tester.widget<Text>(titleWidget);
    expect(
      titleText.data?.startsWith('地点詳細'),
      isTrue,
      reason: 'MarkDetail AppBarタイトルが「地点詳細」で始まること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-005: LinkDetail — ヘッダタイトルが「区間詳細：(名称)」形式であること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-005: LinkDetail — AppBarタイトルが「区間詳細」または「区間詳細：(名称)」形式で表示されること',
      (tester) async {
    final opened = await openLinkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-005: LinkDetailを開けなかったためスキップします');
      return;
    }

    final titleWidget = find.byKey(const Key('linkDetail_appBar_title'));
    expect(
      titleWidget,
      findsOneWidget,
      reason: 'linkDetail_appBar_title キーを持つウィジェットが存在すること',
    );

    final titleText = tester.widget<Text>(titleWidget);
    expect(
      titleText.data?.startsWith('区間詳細'),
      isTrue,
      reason: 'LinkDetail AppBarタイトルが「区間詳細」で始まること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-006: PaymentDetail — ヘッダタイトルが「支払詳細」であること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-006: PaymentDetail — AppBarタイトルが「支払詳細」固定で表示されること',
      (tester) async {
    final opened = await openPaymentDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-006: PaymentDetailを開けなかったためスキップします');
      return;
    }

    final titleWidget = find.byKey(const Key('paymentDetail_appBar_title'));
    expect(
      titleWidget,
      findsOneWidget,
      reason: 'paymentDetail_appBar_title キーを持つウィジェットが存在すること',
    );

    final titleText = tester.widget<Text>(titleWidget);
    expect(
      titleText.data,
      equals('支払詳細'),
      reason: 'PaymentDetail AppBarタイトルが「支払詳細」であること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-007: MarkDetail — キャンセル・保存ボタンがフォーム最下部に表示されること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-007: MarkDetail — フォーム最下部にキャンセルボタンと保存ボタンが横並びで表示されること',
      (tester) async {
    final opened = await openMarkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-007: MarkDetailを開けなかったためスキップします');
      return;
    }

    // フォームを最下部までスクロール
    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('markDetail_button_cancel')).evaluate().isNotEmpty &&
            find.byKey(const Key('markDetail_button_save')).evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('markDetail_button_cancel')),
      findsOneWidget,
      reason: 'MarkDetail フォーム最下部にキャンセルボタンが表示されること',
    );
  });

  testWidgets(
      'TC-DSI-007b: MarkDetail — フォーム最下部に保存ボタンが表示されること',
      (tester) async {
    final opened = await openMarkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-007b: MarkDetailを開けなかったためスキップします');
      return;
    }

    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('markDetail_button_save')).evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('markDetail_button_save')),
      findsOneWidget,
      reason: 'MarkDetail フォーム最下部に保存ボタンが表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-008: LinkDetail — キャンセル・保存ボタンがフォーム最下部に表示されること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-008: LinkDetail — フォーム最下部にキャンセルボタンが表示されること',
      (tester) async {
    final opened = await openLinkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-008: LinkDetailを開けなかったためスキップします');
      return;
    }

    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('linkDetail_button_cancel')).evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('linkDetail_button_cancel')),
      findsOneWidget,
      reason: 'LinkDetail フォーム最下部にキャンセルボタンが表示されること',
    );
  });

  testWidgets(
      'TC-DSI-008b: LinkDetail — フォーム最下部に保存ボタンが表示されること',
      (tester) async {
    final opened = await openLinkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-008b: LinkDetailを開けなかったためスキップします');
      return;
    }

    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('linkDetail_button_save')).evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('linkDetail_button_save')),
      findsOneWidget,
      reason: 'LinkDetail フォーム最下部に保存ボタンが表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-009: PaymentDetail — キャンセル・保存ボタンがフォーム最下部に表示されること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-009: PaymentDetail — フォーム最下部にキャンセルボタンが表示されること',
      (tester) async {
    final opened = await openPaymentDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-009: PaymentDetailを開けなかったためスキップします');
      return;
    }

    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('paymentDetail_button_cancel')).evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('paymentDetail_button_cancel')),
      findsOneWidget,
      reason: 'PaymentDetail フォーム最下部にキャンセルボタンが表示されること',
    );
  });

  testWidgets(
      'TC-DSI-009b: PaymentDetail — フォーム最下部に保存ボタンが表示されること',
      (tester) async {
    final opened = await openPaymentDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-009b: PaymentDetailを開けなかったためスキップします');
      return;
    }

    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('paymentDetail_button_save')).evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('paymentDetail_button_save')),
      findsOneWidget,
      reason: 'PaymentDetail フォーム最下部に保存ボタンが表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-010: MarkDetail — キャンセルタップで画面が閉じること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-010: MarkDetail — キャンセルボタンタップでMichiInfo画面に戻ること',
      (tester) async {
    final opened = await openMarkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-010: MarkDetailを開けなかったためスキップします');
      return;
    }

    // フォームを最下部までスクロールしてキャンセルボタンを表示
    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('markDetail_button_cancel')).evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    final cancelButton = find.byKey(const Key('markDetail_button_cancel'));
    expect(cancelButton, findsOneWidget, reason: 'キャンセルボタンが表示されること');

    await tester.ensureVisible(cancelButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(cancelButton);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // MarkDetailが閉じてMichiInfo画面に戻ることを確認
      // MichiInfo画面ではFABが表示される
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty ||
          find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('markDetail_button_cancel')),
      findsNothing,
      reason: 'キャンセルボタンタップ後にMarkDetail画面が閉じること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-011: LinkDetail — キャンセルタップで画面が閉じること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-011: LinkDetail — キャンセルボタンタップで前の画面に戻ること',
      (tester) async {
    final opened = await openLinkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-011: LinkDetailを開けなかったためスキップします');
      return;
    }

    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('linkDetail_button_cancel')).evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    final cancelButton = find.byKey(const Key('linkDetail_button_cancel'));
    expect(cancelButton, findsOneWidget, reason: 'LinkDetailキャンセルボタンが表示されること');

    await tester.ensureVisible(cancelButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(cancelButton);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty ||
          find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('linkDetail_button_cancel')),
      findsNothing,
      reason: 'キャンセルボタンタップ後にLinkDetail画面が閉じること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-012: PaymentDetail — キャンセルタップで画面が閉じること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-012: PaymentDetail — キャンセルボタンタップで前の画面に戻ること',
      (tester) async {
    final opened = await openPaymentDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-012: PaymentDetailを開けなかったためスキップします');
      return;
    }

    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('paymentDetail_button_cancel')).evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    final cancelButton = find.byKey(const Key('paymentDetail_button_cancel'));
    expect(cancelButton, findsOneWidget, reason: 'PaymentDetailキャンセルボタンが表示されること');

    await tester.ensureVisible(cancelButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(cancelButton);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('支払').evaluate().isNotEmpty ||
          find.byType(ListView).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('paymentDetail_button_cancel')),
      findsNothing,
      reason: 'キャンセルボタンタップ後にPaymentDetail画面が閉じること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-013: MarkDetail — 保存タップで保存されて画面が閉じること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-013: MarkDetail — 保存ボタンタップで保存処理が実行されてMichiInfo画面に戻ること',
      (tester) async {
    final opened = await openMarkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-013: MarkDetailを開けなかったためスキップします');
      return;
    }

    // フォームを最下部までスクロールして保存ボタンを表示
    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('markDetail_button_save')).evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    final saveButton = find.byKey(const Key('markDetail_button_save'));
    expect(saveButton, findsOneWidget, reason: '保存ボタンが表示されること');

    await tester.ensureVisible(saveButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(saveButton);

    // 保存処理が完了してMarkDetailが閉じるまで待つ
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty ||
          find.text('大涌谷').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('markDetail_button_save')),
      findsNothing,
      reason: '保存ボタンタップ後にMarkDetail画面が閉じること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-014: LinkDetail — 保存タップで保存されて画面が閉じること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-014: LinkDetail — 保存ボタンタップで保存処理が実行されて前の画面に戻ること',
      (tester) async {
    final opened = await openLinkDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-014: LinkDetailを開けなかったためスキップします');
      return;
    }

    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('linkDetail_button_save')).evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    final saveButton = find.byKey(const Key('linkDetail_button_save'));
    expect(saveButton, findsOneWidget, reason: 'LinkDetail保存ボタンが表示されること');

    await tester.ensureVisible(saveButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(saveButton);

    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty ||
          find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('linkDetail_button_save')),
      findsNothing,
      reason: '保存ボタンタップ後にLinkDetail画面が閉じること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-DSI-015: PaymentDetail — 保存タップで保存されて画面が閉じること
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-DSI-015: PaymentDetail — 保存ボタンタップで保存処理が実行されてPaymentInfo画面に戻ること',
      (tester) async {
    final opened = await openPaymentDetail(tester);
    if (!opened) {
      markTestSkipped('TC-DSI-015: PaymentDetailを開けなかったためスキップします');
      return;
    }

    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      for (var i = 0; i < 5; i++) {
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byKey(const Key('paymentDetail_button_save')).evaluate().isNotEmpty) break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    final saveButton = find.byKey(const Key('paymentDetail_button_save'));
    expect(saveButton, findsOneWidget, reason: 'PaymentDetail保存ボタンが表示されること');

    await tester.ensureVisible(saveButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(saveButton);

    // 保存処理が完了してPaymentDetailが閉じるまで待つ
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('支払').evaluate().isNotEmpty &&
          find.byKey(const Key('paymentDetail_button_save')).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('paymentDetail_button_save')),
      findsNothing,
      reason: '保存ボタンタップ後にPaymentDetail画面が閉じること',
    );
  });
}
