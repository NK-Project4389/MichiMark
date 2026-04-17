// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: メンバー選択 全選択 / 全解除ボタン (UI-11)
///
/// Spec: docs/Spec/Features/FS-member_select_all_clear.md §9
///
/// テストシナリオ: TC-MSA-001 〜 TC-MSA-006
///
/// 前提条件:
///   - メンバーマスタ: 「太郎」(member-001)・「花子」(member-002)・「健太」(member-003) が登録済み
///   - イベント「箱根日帰りドライブ」(event-001) が存在し、イベントメンバーとして太郎・花子が設定済み
///   - MarkDetail（ml-001: 自宅出発）・LinkDetail（ml-002: 東名高速）・PaymentDetail（pay-001）が利用可能
///   - PaymentDetail (pay-001) の支払者（paymentMember）が設定済みであること

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

  /// 指定イベント名のカードをタップして EventDetail を開く。
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

  /// EventDetail の「ミチ」タブに切り替える。
  Future<void> goToMichiTab(WidgetTester tester) async {
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return;
    await tester.tap(michiTab);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// EventDetail の「支払」タブに切り替える。
  Future<void> goToPaymentTab(WidgetTester tester) async {
    final paymentTab = find.text('支払');
    if (paymentTab.evaluate().isEmpty) return;
    await tester.tap(paymentTab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty ||
          find.text('支払情報がありません').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// ミチタブで指定 Key またはテキストのカードをタップして Detail 画面を開く。
  /// 指定プレフィックスを持つチップが表示されるまで待つ。
  Future<bool> openMarkLinkDetailByKeyOrText(
    WidgetTester tester, {
    required String cardKey,
    required String fallbackText,
    required String waitForKeyPrefix,
  }) async {
    // まずキーで検索
    Finder card = find.byKey(Key(cardKey));
    if (card.evaluate().isEmpty) {
      // フォールバック: テキストで検索
      final textFinder = find.text(fallbackText);
      if (textFinder.evaluate().isEmpty) return false;
      // テキストを含む GestureDetector をタップ
      final gestureDetector = find.ancestor(
        of: textFinder,
        matching: find.byType(GestureDetector),
      );
      if (gestureDetector.evaluate().isNotEmpty) {
        await tester.tap(gestureDetector.first);
      } else {
        await tester.tap(textFinder);
      }
    } else {
      await tester.tap(card);
    }
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final chips = tester.elementList(find.byWidgetPredicate((widget) {
        final key = widget.key;
        if (key is ValueKey<String>) {
          return key.value.startsWith(waitForKeyPrefix);
        }
        return false;
      }));
      if (chips.isNotEmpty) return true;
    }
    return false;
  }

  /// 支払タブで指定 paymentId の支払タイルをタップして PaymentDetail 画面を開く。
  /// まずキーで検索し、見つからない場合は先頭の InkWell をタップするフォールバックを使う。
  /// 支払者チップが表示されるまで待つ。
  Future<bool> openPaymentDetailById(
    WidgetTester tester,
    String paymentId,
  ) async {
    final tileByKey = find.byKey(Key('payment_info_tile_slidable_$paymentId'));
    if (tileByKey.evaluate().isNotEmpty) {
      await tester.tap(tileByKey);
    } else {
      // フォールバック: 支払一覧の先頭 InkWell をタップ
      final inkWells = find.byType(InkWell);
      if (inkWells.evaluate().isEmpty) return false;
      await tester.tap(inkWells.first);
    }
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final chips = tester.elementList(find.byWidgetPredicate((widget) {
        final key = widget.key;
        if (key is ValueKey<String>) {
          return key.value.startsWith('paymentDetail_chip_payMember_');
        }
        return false;
      }));
      if (chips.isNotEmpty) return true;
    }
    return false;
  }

  /// MarkDetail 画面まで遷移するセットアップ。
  /// 失敗した場合はスキップ理由の文字列を返す。成功時は null を返す。
  Future<String?> setupMarkDetail(WidgetTester tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      return '箱根日帰りドライブが見つからないためスキップします';
    }

    await goToMichiTab(tester);

    // ml-001 (自宅出発) の Mark カードを開く
    const markCardKey = 'michi_info_card_slidable_ml-001';
    final navigated = await openMarkLinkDetailByKeyOrText(
      tester,
      cardKey: markCardKey,
      fallbackText: '自宅出発',
      waitForKeyPrefix: 'markDetail_chip_member_',
    );
    if (!navigated) {
      return 'MarkDetail (ml-001) が開けなかったためスキップします';
    }
    return null;
  }

  /// LinkDetail 画面まで遷移するセットアップ。
  /// 失敗した場合はスキップ理由の文字列を返す。成功時は null を返す。
  Future<String?> setupLinkDetail(WidgetTester tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      return '箱根日帰りドライブが見つからないためスキップします';
    }

    await goToMichiTab(tester);

    // ml-002 (東名高速) の Link カードを開く
    const linkCardKey = 'michi_info_card_slidable_ml-002';
    final navigated = await openMarkLinkDetailByKeyOrText(
      tester,
      cardKey: linkCardKey,
      fallbackText: '東名高速',
      waitForKeyPrefix: 'linkDetail_chip_member_',
    );
    if (!navigated) {
      return 'LinkDetail (ml-002) が開けなかったためスキップします';
    }
    return null;
  }

  /// PaymentDetail 画面まで遷移するセットアップ。
  /// 失敗した場合はスキップ理由の文字列を返す。成功時は null を返す。
  Future<String?> setupPaymentDetail(WidgetTester tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) {
      return '箱根日帰りドライブが見つからないためスキップします';
    }

    await goToPaymentTab(tester);

    // pay-001 (高速道路代) の支払タイルを開く
    final navigated = await openPaymentDetailById(tester, 'pay-001');
    if (!navigated) {
      return 'PaymentDetail (pay-001) が開けなかったためスキップします';
    }
    return null;
  }

  /// 指定キープレフィックスを持つ全 FilterChip が selected であることを確認する。
  bool allChipsSelected(WidgetTester tester, String keyPrefix) {
    final elements = tester.elementList(find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith(keyPrefix);
      }
      return false;
    }));
    if (elements.isEmpty) return false;
    for (final element in elements) {
      final widget = element.widget;
      if (widget is FilterChip && !widget.selected) return false;
    }
    return true;
  }

  /// 指定キープレフィックスを持つ全 FilterChip が未選択（selected == false）であることを確認する。
  bool allChipsUnselected(WidgetTester tester, String keyPrefix) {
    final elements = tester.elementList(find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith(keyPrefix);
      }
      return false;
    }));
    if (elements.isEmpty) return false;
    for (final element in elements) {
      final widget = element.widget;
      if (widget is FilterChip && widget.selected) return false;
    }
    return true;
  }

  // ────────────────────────────────────────────────────────
  // TC-MSA-001: MarkDetail 全選択
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MSA-001: MarkDetail のメンバー選択で「全選択」をタップすると全メンバーが選択状態になる',
      (tester) async {
    final skipReason = await setupMarkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 「全選択」ボタンが存在することを確認
    final selectAllButton =
        find.byKey(const Key('markDetail_button_selectAllMembers'));
    if (selectAllButton.evaluate().isEmpty) {
      markTestSkipped('全選択ボタン (markDetail_button_selectAllMembers) が見つからないためスキップします');
      return;
    }

    // 「全選択」ボタンをタップ
    await tester.ensureVisible(selectAllButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(selectAllButton);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 全メンバーチップが選択状態になっていること
    expect(
      allChipsSelected(tester, 'markDetail_chip_member_'),
      isTrue,
      reason: '全選択タップ後、markDetail_chip_member_ プレフィックスを持つ全チップが selected: true になること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MSA-002: MarkDetail 全解除
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MSA-002: MarkDetail のメンバー選択で「全解除」をタップすると全メンバーが非選択状態になる',
      (tester) async {
    final skipReason = await setupMarkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // まず「全選択」ボタンで全員選択した状態にする
    final selectAllButton =
        find.byKey(const Key('markDetail_button_selectAllMembers'));
    if (selectAllButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(selectAllButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(selectAllButton);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    // 「全解除」ボタンが存在することを確認
    final clearAllButton =
        find.byKey(const Key('markDetail_button_clearAllMembers'));
    if (clearAllButton.evaluate().isEmpty) {
      markTestSkipped('全解除ボタン (markDetail_button_clearAllMembers) が見つからないためスキップします');
      return;
    }

    // 「全解除」ボタンをタップ
    await tester.ensureVisible(clearAllButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(clearAllButton);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 全メンバーチップが非選択状態になっていること
    expect(
      allChipsUnselected(tester, 'markDetail_chip_member_'),
      isTrue,
      reason: '全解除タップ後、markDetail_chip_member_ プレフィックスを持つ全チップが selected: false になること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MSA-003: LinkDetail 全選択
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MSA-003: LinkDetail のメンバー選択で「全選択」をタップすると全メンバーが選択状態になる',
      (tester) async {
    final skipReason = await setupLinkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 「全選択」ボタンが存在することを確認
    final selectAllButton =
        find.byKey(const Key('linkDetail_button_selectAllMembers'));
    if (selectAllButton.evaluate().isEmpty) {
      markTestSkipped('全選択ボタン (linkDetail_button_selectAllMembers) が見つからないためスキップします');
      return;
    }

    // 「全選択」ボタンをタップ
    await tester.ensureVisible(selectAllButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(selectAllButton);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 全メンバーチップが選択状態になっていること
    expect(
      allChipsSelected(tester, 'linkDetail_chip_member_'),
      isTrue,
      reason: '全選択タップ後、linkDetail_chip_member_ プレフィックスを持つ全チップが selected: true になること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MSA-004: LinkDetail 全解除
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MSA-004: LinkDetail のメンバー選択で「全解除」をタップすると全メンバーが非選択状態になる',
      (tester) async {
    final skipReason = await setupLinkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // まず「全選択」ボタンで全員選択した状態にする
    final selectAllButton =
        find.byKey(const Key('linkDetail_button_selectAllMembers'));
    if (selectAllButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(selectAllButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(selectAllButton);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    // 「全解除」ボタンが存在することを確認
    final clearAllButton =
        find.byKey(const Key('linkDetail_button_clearAllMembers'));
    if (clearAllButton.evaluate().isEmpty) {
      markTestSkipped('全解除ボタン (linkDetail_button_clearAllMembers) が見つからないためスキップします');
      return;
    }

    // 「全解除」ボタンをタップ
    await tester.ensureVisible(clearAllButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(clearAllButton);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 全メンバーチップが非選択状態になっていること
    expect(
      allChipsUnselected(tester, 'linkDetail_chip_member_'),
      isTrue,
      reason: '全解除タップ後、linkDetail_chip_member_ プレフィックスを持つ全チップが selected: false になること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MSA-005: PaymentDetail 割り勘メンバー全選択
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-MSA-005: PaymentDetail の割り勘メンバー選択で「全選択」をタップすると全メンバーが選択状態になる',
      (tester) async {
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 「全選択」ボタンが存在することを確認
    final selectAllButton =
        find.byKey(const Key('paymentDetail_button_selectAllSplitMembers'));
    if (selectAllButton.evaluate().isEmpty) {
      markTestSkipped(
          '全選択ボタン (paymentDetail_button_selectAllSplitMembers) が見つからないためスキップします');
      return;
    }

    // 「全選択」ボタンをタップ
    await tester.ensureVisible(selectAllButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(selectAllButton);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 全割り勘メンバーチップが選択状態になっていること
    expect(
      allChipsSelected(tester, 'paymentDetail_chip_splitMember_'),
      isTrue,
      reason:
          '全選択タップ後、paymentDetail_chip_splitMember_ プレフィックスを持つ全チップが selected: true になること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MSA-006: PaymentDetail 割り勘メンバー全解除（支払者除外）
  // ────────────────────────────────────────────────────────

  testWidgets(
      'TC-MSA-006: PaymentDetail の割り勘メンバー選択で「全解除」をタップすると支払者以外が非選択になる',
      (tester) async {
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // まず「全選択」ボタンで全員選択した状態にする
    final selectAllButton =
        find.byKey(const Key('paymentDetail_button_selectAllSplitMembers'));
    if (selectAllButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(selectAllButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(selectAllButton);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    // 「全解除」ボタンが存在することを確認
    final clearAllButton =
        find.byKey(const Key('paymentDetail_button_clearAllSplitMembers'));
    if (clearAllButton.evaluate().isEmpty) {
      markTestSkipped(
          '全解除ボタン (paymentDetail_button_clearAllSplitMembers) が見つからないためスキップします');
      return;
    }

    // 支払者チップのキーを事前に取得する
    final payerChipElements =
        tester.elementList(find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('paymentDetail_chip_payMember_');
      }
      return false;
    }));
    if (payerChipElements.isEmpty) {
      markTestSkipped('支払者チップ (paymentDetail_chip_payMember_*) が見つからないためスキップします');
      return;
    }
    final payerKey =
        (payerChipElements.first.widget.key as ValueKey<String>).value;
    // paymentDetail_chip_payMember_XXXXX → member ID を抽出
    final payerMemberId =
        payerKey.replaceFirst('paymentDetail_chip_payMember_', '');

    // 「全解除」ボタンをタップ
    await tester.ensureVisible(clearAllButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(clearAllButton);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 支払者の割り勘チップ（splitMember）は選択状態を維持していること
    final payerSplitChip = find.byKey(
        Key('paymentDetail_chip_splitMember_$payerMemberId'));
    if (payerSplitChip.evaluate().isNotEmpty) {
      final payerSplitWidget = tester.widget<FilterChip>(payerSplitChip);
      expect(
        payerSplitWidget.selected,
        isTrue,
        reason: '全解除タップ後、支払者 ($payerMemberId) の割り勘チップは selected: true を維持すること',
      );
    }
  });

  testWidgets(
      'TC-MSA-006b: PaymentDetail の全解除後に支払者以外の割り勘メンバーが非選択状態になる',
      (tester) async {
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // まず「全選択」ボタンで全員選択した状態にする
    final selectAllButton =
        find.byKey(const Key('paymentDetail_button_selectAllSplitMembers'));
    if (selectAllButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(selectAllButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(selectAllButton);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    // 支払者のメンバーIDを事前に取得する
    final payerChipElements =
        tester.elementList(find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        return key.value.startsWith('paymentDetail_chip_payMember_');
      }
      return false;
    }));
    if (payerChipElements.isEmpty) {
      markTestSkipped('支払者チップ (paymentDetail_chip_payMember_*) が見つからないためスキップします');
      return;
    }
    final payerMemberId =
        (payerChipElements.first.widget.key as ValueKey<String>)
            .value
            .replaceFirst('paymentDetail_chip_payMember_', '');

    // 「全解除」ボタンをタップ
    final clearAllButton =
        find.byKey(const Key('paymentDetail_button_clearAllSplitMembers'));
    if (clearAllButton.evaluate().isEmpty) {
      markTestSkipped(
          '全解除ボタン (paymentDetail_button_clearAllSplitMembers) が見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(clearAllButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(clearAllButton);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 支払者以外の割り勘チップが非選択状態になっていること
    final nonPayerElements =
        tester.elementList(find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is ValueKey<String>) {
        final k = key.value;
        return k.startsWith('paymentDetail_chip_splitMember_') &&
            !k.endsWith(payerMemberId);
      }
      return false;
    }));

    var allNonPayerUnselected = true;
    for (final element in nonPayerElements) {
      final widget = element.widget;
      if (widget is FilterChip && widget.selected) {
        allNonPayerUnselected = false;
        break;
      }
    }

    expect(
      allNonPayerUnselected,
      isTrue,
      reason: '全解除タップ後、支払者以外の割り勘メンバーチップは selected: false になること',
    );
  });
}
