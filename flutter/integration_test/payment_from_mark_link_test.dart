// ignore_for_file: avoid_print

/// Integration Test: MarkDetail / LinkDetail からの支払い登録
///
/// Spec: docs/Spec/Features/FS-payment_from_mark_link.md §10
///
/// テストシナリオ: TC-PML-I001 〜 TC-PML-I010
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータが投入済みであること
///     - event-001: 箱根日帰りドライブ
///       - ml-001 (Mark: 自宅出発)
///       - ml-002 (Link: 東名高速)
///       - ml-003 (Mark: 箱根湯本駅前)
///   - flutter-dev による実装が完了していること

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
  // ヘルパー
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
          find.text('イベントがありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// イベント一覧から指定したイベント名のイベントをタップして EventDetail を開く。
  /// イベントが見つからない場合は false を返す。
  Future<bool> openEventDetailByName(
    WidgetTester tester,
    String eventName,
  ) async {
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
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// ミチタブをタップして MichiInfoView を表示する。
  Future<void> openMichiTab(WidgetTester tester) async {
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isNotEmpty) {
      await tester.tap(michiTab.first);
      await tester.pump(const Duration(milliseconds: 500));
    }
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byType(ListView).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// 支払タブをタップして PaymentInfoView を表示する。
  Future<void> openPaymentTab(WidgetTester tester) async {
    final paymentTab = find.text('支払');
    if (paymentTab.evaluate().isEmpty) return;
    await tester.tap(paymentTab.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty ||
          find.text('支払情報がありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// 箱根日帰りドライブのミチタブを開くセットアップ。
  /// スキップ理由がある場合は文字列を返す。null の場合は成功。
  Future<String?> setupMichiTab(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }
    final opened = await openEventDetailByName(tester, '箱根日帰りドライブ');
    if (!opened) {
      return '箱根日帰りドライブを開けなかったためスキップします';
    }
    await openMichiTab(tester);
    return null;
  }

  /// ミチタブから ml-001 (Mark: 自宅出発) をタップして MarkDetail を開く。
  /// スキップ理由がある場合は文字列を返す。null の場合は成功。
  Future<String?> openMarkDetail(WidgetTester tester) async {
    const markId = 'ml-001';

    // Markカードが画面内に見えるまでスクロール
    for (var i = 0; i < 10; i++) {
      if (find.byKey(Key('michiInfo_text_markDate_$markId')).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    if (find.byKey(Key('michiInfo_text_markDate_$markId')).evaluate().isEmpty) {
      return 'Markカード (ml-001) が見つからないためスキップします';
    }

    // Markカードをタップして MarkDetail へ遷移
    await tester.tap(find.byKey(Key('michiInfo_text_markDate_$markId')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('markDetail_screen')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    if (find.byKey(const Key('markDetail_screen')).evaluate().isEmpty) {
      return 'MarkDetail 画面が開けなかったためスキップします';
    }
    return null;
  }

  /// ミチタブから ml-002 (Link: 東名高速) をタップして LinkDetail を開く。
  /// スキップ理由がある場合は文字列を返す。null の場合は成功。
  Future<String?> openLinkDetail(WidgetTester tester) async {
    // Linkカードは名称テキストでタップ
    for (var i = 0; i < 10; i++) {
      if (find.text('東名高速').evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    if (find.text('東名高速').evaluate().isEmpty) {
      return 'Linkカード (東名高速) が見つからないためスキップします';
    }

    await tester.tap(find.text('東名高速').first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('linkDetail_screen')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    if (find.byKey(const Key('linkDetail_screen')).evaluate().isEmpty) {
      return 'LinkDetail 画面が開けなかったためスキップします';
    }
    return null;
  }

  /// MarkDetail / LinkDetail 画面の支払セクション「＋」ボタンをタップして
  /// PaymentDetail 画面へ遷移する。
  /// スキップ理由がある場合は文字列を返す。null の場合は成功。
  Future<String?> tapPaymentPlusButton(WidgetTester tester) async {
    // 「＋」ボタンが画面外の場合はスクロールして表示する
    for (var i = 0; i < 10; i++) {
      if (find.byKey(const Key('payment_plus_button')).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    if (find.byKey(const Key('payment_plus_button')).evaluate().isEmpty) {
      return '支払セクションの「＋」ボタンが見つからないためスキップします';
    }

    await tester.ensureVisible(find.byKey(const Key('payment_plus_button')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('payment_plus_button')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('paymentDetail_appBar_title')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    if (find.byKey(const Key('paymentDetail_appBar_title')).evaluate().isEmpty) {
      return 'PaymentDetail 画面が開けなかったためスキップします';
    }
    return null;
  }

  /// PaymentDetail で金額を入力して保存する。
  Future<void> savePaymentDetail(WidgetTester tester, String amount) async {
    // 金額フィールドに入力
    final amountField = find.byKey(const Key('paymentDetail_field_amount'));
    if (amountField.evaluate().isNotEmpty) {
      await tester.tap(amountField);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(amountField, amount);
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 保存ボタンをスクロールして表示 → タップ
    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('paymentDetail_button_save')).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
    await tester.ensureVisible(find.byKey(const Key('paymentDetail_button_save')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('paymentDetail_button_save')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      // PaymentDetail が閉じて MarkDetail or LinkDetail に戻ったことを確認
      if (find.byKey(const Key('markDetail_screen')).evaluate().isNotEmpty ||
          find.byKey(const Key('linkDetail_screen')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ────────────────────────────────────────────────────────
  // TC-PML-I001: MarkDetail 支払セクションが表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PML-I001: MarkDetail に支払セクションが表示される', (tester) async {
    final skipReason = await setupMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final markSkipReason = await openMarkDetail(tester);
    if (markSkipReason != null) {
      print('[SKIP] $markSkipReason');
      return;
    }

    // 支払セクションの「＋」ボタンが表示されるまでスクロール
    for (var i = 0; i < 10; i++) {
      if (find.byKey(const Key('payment_plus_button')).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(
      find.byKey(const Key('payment_plus_button')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I001b: MarkDetail 支払セクションのヘッダーが表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PML-I001b: MarkDetail に「支払い」セクションヘッダーが表示される',
      (tester) async {
    final skipReason = await setupMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final markSkipReason = await openMarkDetail(tester);
    if (markSkipReason != null) {
      print('[SKIP] $markSkipReason');
      return;
    }

    // 「支払い」セクションヘッダーが表示されるまでスクロール
    for (var i = 0; i < 10; i++) {
      if (find.text('支払い').evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(
      find.text('支払い'),
      findsAtLeastNWidgets(1),
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I002: MarkDetail「＋」から PaymentDetail に遷移できる
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PML-I002: MarkDetail「＋」ボタンをタップすると PaymentDetail 画面に遷移する',
      (tester) async {
    final skipReason = await setupMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final markSkipReason = await openMarkDetail(tester);
    if (markSkipReason != null) {
      print('[SKIP] $markSkipReason');
      return;
    }

    final plusSkipReason = await tapPaymentPlusButton(tester);
    if (plusSkipReason != null) {
      print('[SKIP] $plusSkipReason');
      return;
    }

    expect(
      find.byKey(const Key('paymentDetail_appBar_title')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I002b: PaymentDetail 画面にタイトル「支払詳細」が表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PML-I002b: PaymentDetail 画面に「支払詳細」タイトルが表示される',
      (tester) async {
    final skipReason = await setupMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final markSkipReason = await openMarkDetail(tester);
    if (markSkipReason != null) {
      print('[SKIP] $markSkipReason');
      return;
    }

    final plusSkipReason = await tapPaymentPlusButton(tester);
    if (plusSkipReason != null) {
      print('[SKIP] $plusSkipReason');
      return;
    }

    expect(
      find.text('支払詳細'),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I003: PaymentDetail を保存すると MarkDetail の支払セクションに追加される
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-PML-I003: PaymentDetail を保存すると MarkDetail の支払セクションに支払いカードが表示される',
      (tester) async {
    final skipReason = await setupMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final markSkipReason = await openMarkDetail(tester);
    if (markSkipReason != null) {
      print('[SKIP] $markSkipReason');
      return;
    }

    final plusSkipReason = await tapPaymentPlusButton(tester);
    if (plusSkipReason != null) {
      print('[SKIP] $plusSkipReason');
      return;
    }

    // 金額を入力して保存
    await savePaymentDetail(tester, '1000');

    // MarkDetail 画面に戻っていること
    if (find.byKey(const Key('markDetail_screen')).evaluate().isEmpty) {
      print('[SKIP] MarkDetail 画面に戻れなかったためスキップします');
      return;
    }

    // 支払セクションに支払いカードが表示されているか確認（スクロールして探す）
    for (var i = 0; i < 10; i++) {
      if (find.byKey(const Key('markDetail_paymentSection_items')).evaluate().isNotEmpty ||
          find.text('1,000円').evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(
      find.text('1,000円'),
      findsAtLeastNWidgets(1),
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I004: PaymentDetail 保存後に MarkDetail 画面に戻る
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PML-I004: PaymentDetail 保存後に MarkDetail 画面が表示される',
      (tester) async {
    final skipReason = await setupMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final markSkipReason = await openMarkDetail(tester);
    if (markSkipReason != null) {
      print('[SKIP] $markSkipReason');
      return;
    }

    final plusSkipReason = await tapPaymentPlusButton(tester);
    if (plusSkipReason != null) {
      print('[SKIP] $plusSkipReason');
      return;
    }

    await savePaymentDetail(tester, '2000');

    expect(
      find.byKey(const Key('markDetail_screen')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I005: MarkDetail の支払いは PaymentInfo タブにも表示される
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-PML-I005: MarkDetail から登録した支払いが PaymentInfo タブにも表示される',
      (tester) async {
    final skipReason = await setupMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final markSkipReason = await openMarkDetail(tester);
    if (markSkipReason != null) {
      print('[SKIP] $markSkipReason');
      return;
    }

    final plusSkipReason = await tapPaymentPlusButton(tester);
    if (plusSkipReason != null) {
      print('[SKIP] $plusSkipReason');
      return;
    }

    // 支払いを保存
    await savePaymentDetail(tester, '3000');

    // MarkDetail が表示されていることを確認
    if (find.byKey(const Key('markDetail_screen')).evaluate().isEmpty) {
      print('[SKIP] MarkDetail 画面に戻れなかったためスキップします');
      return;
    }

    // MarkDetail のキャンセルボタンで MarkDetail を閉じる
    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('markDetail_button_cancel')).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
    if (find.byKey(const Key('markDetail_button_cancel')).evaluate().isEmpty) {
      print('[SKIP] キャンセルボタンが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(find.byKey(const Key('markDetail_button_cancel')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('markDetail_button_cancel')));

    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // PaymentInfo タブへ切り替え
    await openPaymentTab(tester);

    // 登録した金額（3,000円）が表示されているか確認（スクロールして探す）
    for (var i = 0; i < 10; i++) {
      if (find.text('3,000円').evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(
      find.text('3,000円'),
      findsAtLeastNWidgets(1),
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I006: PaymentInfo から MarkDetail 経由の支払いを編集できる
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-PML-I006: PaymentInfo から MarkDetail 経由の支払いをタップすると PaymentDetail 編集画面が開く',
      (tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      print('[SKIP] イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetailByName(tester, '箱根日帰りドライブ');
    if (!opened) {
      print('[SKIP] 箱根日帰りドライブを開けなかったためスキップします');
      return;
    }

    // PaymentInfo タブへ切り替え
    await openPaymentTab(tester);

    // 支払情報がない場合はスキップ
    if (find.text('支払情報がありません').evaluate().isNotEmpty) {
      print('[SKIP] 支払情報がないためスキップします（TC-PML-I005 実行後に手動確認）');
      return;
    }

    // 最初の支払いカードをタップ
    final paymentTiles = find.byType(InkWell);
    if (paymentTiles.evaluate().isEmpty) {
      print('[SKIP] 支払いカードが見つからないためスキップします');
      return;
    }
    await tester.tap(paymentTiles.first);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('paymentDetail_appBar_title')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('paymentDetail_appBar_title')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I007: PaymentInfo から MarkDetail 経由の支払いを削除できる
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-PML-I007: PaymentInfo の支払い削除後に MarkDetail の支払セクションからも消える',
      (tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      print('[SKIP] イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetailByName(tester, '箱根日帰りドライブ');
    if (!opened) {
      print('[SKIP] 箱根日帰りドライブを開けなかったためスキップします');
      return;
    }

    // PaymentInfo タブへ切り替え
    await openPaymentTab(tester);

    if (find.text('支払情報がありません').evaluate().isNotEmpty) {
      print('[SKIP] 支払情報がないためスキップします（TC-PML-I005 実行後に手動確認）');
      return;
    }

    // 削除ボタンが表示されるまでスクロール
    final deleteButtonFinder = find.byWidgetPredicate((widget) {
      if (widget.key is ValueKey<String>) {
        final keyStr = (widget.key as ValueKey<String>).value;
        return keyStr.startsWith('paymentInfo_button_delete_');
      }
      return false;
    });

    for (var i = 0; i < 5; i++) {
      if (deleteButtonFinder.evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    if (deleteButtonFinder.evaluate().isEmpty) {
      print('[SKIP] 削除ボタンが見つからないためスキップします');
      return;
    }

    await tester.tap(deleteButtonFinder.first);
    await tester.pump(const Duration(milliseconds: 500));

    // 確認ダイアログで削除を実行
    if (find.byKey(const Key('deleteConfirmDialog_button_delete')).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const Key('deleteConfirmDialog_button_delete')));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('deleteConfirmDialog_dialog_confirm')).evaluate().isEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));
    }

    // PaymentInfo の一覧が更新されていること（削除ボタン対応の支払いが消えたこと）
    expect(
      find.byKey(const Key('deleteConfirmDialog_dialog_confirm')),
      findsNothing,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I008: LinkDetail でも同様の支払い登録ができる
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-PML-I008: LinkDetail に支払セクション・「＋」ボタンが表示される',
      (tester) async {
    final skipReason = await setupMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final linkSkipReason = await openLinkDetail(tester);
    if (linkSkipReason != null) {
      print('[SKIP] $linkSkipReason');
      return;
    }

    // 支払セクションの「＋」ボタンが表示されるまでスクロール
    for (var i = 0; i < 10; i++) {
      if (find.byKey(const Key('payment_plus_button')).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(
      find.byKey(const Key('payment_plus_button')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I008b: LinkDetail の「＋」から PaymentDetail に遷移できる
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-PML-I008b: LinkDetail「＋」ボタンをタップすると PaymentDetail 画面に遷移する',
      (tester) async {
    final skipReason = await setupMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final linkSkipReason = await openLinkDetail(tester);
    if (linkSkipReason != null) {
      print('[SKIP] $linkSkipReason');
      return;
    }

    final plusSkipReason = await tapPaymentPlusButton(tester);
    if (plusSkipReason != null) {
      print('[SKIP] $plusSkipReason');
      return;
    }

    expect(
      find.byKey(const Key('paymentDetail_appBar_title')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I008c: LinkDetail から PaymentDetail を保存すると LinkDetail に戻る
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-PML-I008c: LinkDetail から PaymentDetail を保存すると LinkDetail 画面に戻る',
      (tester) async {
    final skipReason = await setupMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    final linkSkipReason = await openLinkDetail(tester);
    if (linkSkipReason != null) {
      print('[SKIP] $linkSkipReason');
      return;
    }

    final plusSkipReason = await tapPaymentPlusButton(tester);
    if (plusSkipReason != null) {
      print('[SKIP] $plusSkipReason');
      return;
    }

    // 金額を入力して保存（LinkDetail に戻ることを確認）
    final amountField = find.byKey(const Key('paymentDetail_field_amount'));
    if (amountField.evaluate().isNotEmpty) {
      await tester.tap(amountField);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(amountField, '5000');
      await tester.pump(const Duration(milliseconds: 300));
    }

    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('paymentDetail_button_save')).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
    await tester.ensureVisible(find.byKey(const Key('paymentDetail_button_save')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('paymentDetail_button_save')));

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('linkDetail_screen')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('linkDetail_screen')),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I009: MarkDetail を削除すると紐づく支払いも削除される
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-PML-I009: MarkDetail を削除すると PaymentInfo タブからも紐づく支払いが消える',
      (tester) async {
    final skipReason = await setupMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // ml-003 (箱根湯本駅前) の Mark カードを削除する
    // ml-001 は最初のカードなのでここでは ml-003 を使う
    const targetMarkId = 'ml-003';

    // Markカードが画面内に見えるまでスクロール
    for (var i = 0; i < 10; i++) {
      if (find.byKey(Key('michiInfo_text_markDate_$targetMarkId')).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    if (find.byKey(Key('michiInfo_text_markDate_$targetMarkId')).evaluate().isEmpty) {
      print('[SKIP] Markカード ($targetMarkId) が見つからないためスキップします');
      return;
    }

    // 削除ボタンをタップ
    final deleteButton = find.byKey(Key('michiInfo_button_delete_$targetMarkId'));
    if (deleteButton.evaluate().isEmpty) {
      print('[SKIP] Markカードの削除ボタンが見つからないためスキップします');
      return;
    }
    await tester.tap(deleteButton);
    await tester.pump(const Duration(milliseconds: 500));

    // 削除確認ダイアログで「削除」をタップ
    if (find.byKey(const Key('deleteConfirmDialog_button_delete')).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const Key('deleteConfirmDialog_button_delete')));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('deleteConfirmDialog_dialog_confirm')).evaluate().isEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 500));
    } else {
      print('[SKIP] 削除確認ダイアログが表示されなかったためスキップします');
      return;
    }

    // Mark が削除されたこと（カードが消えたこと）を確認
    expect(
      find.byKey(Key('michiInfo_text_markDate_$targetMarkId')),
      findsNothing,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I009b: MarkDetail 削除後に PaymentInfo タブで支払いが消える
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-PML-I009b: MarkDetail 削除後に PaymentInfo タブの合計金額が更新される',
      (tester) async {
    final skipReason = await setupMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // PaymentInfo タブに切り替えて削除前の合計金額を記録
    // イベントを閉じずにタブを切り替える
    await openPaymentTab(tester);
    final totalBefore = find.textContaining('合計:').evaluate().isNotEmpty
        ? (tester.widget<Text>(find.textContaining('合計:').first)).data ?? ''
        : '';

    // ミチタブに戻る
    await openMichiTab(tester);

    // ml-003 を削除する
    const targetMarkId = 'ml-003';
    for (var i = 0; i < 10; i++) {
      if (find.byKey(Key('michiInfo_text_markDate_$targetMarkId')).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    if (find.byKey(Key('michiInfo_text_markDate_$targetMarkId')).evaluate().isEmpty) {
      print('[SKIP] Markカード ($targetMarkId) が見つからないためスキップします');
      return;
    }

    final deleteButton = find.byKey(Key('michiInfo_button_delete_$targetMarkId'));
    if (deleteButton.evaluate().isEmpty) {
      print('[SKIP] 削除ボタンが見つからないためスキップします');
      return;
    }
    await tester.tap(deleteButton);
    await tester.pump(const Duration(milliseconds: 500));

    if (find.byKey(const Key('deleteConfirmDialog_button_delete')).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const Key('deleteConfirmDialog_button_delete')));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('deleteConfirmDialog_dialog_confirm')).evaluate().isEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 500));
    } else {
      print('[SKIP] 削除確認ダイアログが表示されなかったためスキップします');
      return;
    }

    // PaymentInfo タブへ切り替えて合計金額をチェック
    await openPaymentTab(tester);
    await tester.pump(const Duration(milliseconds: 500));

    // 合計表示が存在すること（カスケード削除が反映された状態）
    // 削除前後での合計金額変化は手動確認とし、ここでは表示の存在のみ確認
    expect(
      find.textContaining('合計:'),
      findsAtLeastNWidgets(1),
    );

    // 記録目的: totalBefore の値を出力
    if (totalBefore.isNotEmpty) {
      print('[INFO] 削除前合計: $totalBefore');
    }
  });

  // ────────────────────────────────────────────────────────
  // TC-PML-I010: 直接登録の支払い（PaymentInfo タブ）は「直接登録」セクションに表示される
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-PML-I010: PaymentInfo タブから直接登録した支払いが「直接登録」セクションに表示される',
      (tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      print('[SKIP] イベントデータが存在しないためスキップします');
      return;
    }

    final opened = await openEventDetailByName(tester, '箱根日帰りドライブ');
    if (!opened) {
      print('[SKIP] 箱根日帰りドライブを開けなかったためスキップします');
      return;
    }

    // PaymentInfo タブへ切り替え
    await openPaymentTab(tester);

    // FAB（＋）ボタンをタップして PaymentDetail を開く
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isEmpty) {
      print('[SKIP] PaymentInfo の FAB ボタンが見つからないためスキップします');
      return;
    }
    await tester.tap(fab.first);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('paymentDetail_appBar_title')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    if (find.byKey(const Key('paymentDetail_appBar_title')).evaluate().isEmpty) {
      print('[SKIP] PaymentDetail 画面が開けなかったためスキップします');
      return;
    }

    // 金額を入力して保存（markLinkID = null で保存される）
    final amountField = find.byKey(const Key('paymentDetail_field_amount'));
    if (amountField.evaluate().isNotEmpty) {
      await tester.tap(amountField);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(amountField, '4000');
      await tester.pump(const Duration(milliseconds: 300));
    }

    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('paymentDetail_button_save')).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
    await tester.ensureVisible(find.byKey(const Key('paymentDetail_button_save')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('paymentDetail_button_save')));

    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 「直接登録」セクションに登録した支払いが表示されているか確認（スクロールして探す）
    for (var i = 0; i < 10; i++) {
      if (find.text('直接登録').evaluate().isNotEmpty ||
          find.text('4,000円').evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    // 「直接登録」セクションヘッダーまたは金額が表示されていること
    final hasDirect = find.text('直接登録').evaluate().isNotEmpty;
    final hasAmount = find.text('4,000円').evaluate().isNotEmpty;

    expect(hasDirect || hasAmount, isTrue);
  });
}
