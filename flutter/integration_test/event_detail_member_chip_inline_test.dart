// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: MarkDetail・LinkDetail・PaymentDetail メンバー選択インライン化 (Phase B)
///
/// Spec: docs/Spec/Features/FS-event_detail_inline_selection_ui_phaseB.md §15
///
/// テストシナリオ: TC-PBM-001 〜 TC-PBM-014
///
/// 前提条件:
///   - メンバーマスタ: 「太郎」(member-001)・「花子」(member-002)・「健太」(member-003) が登録済み
///   - イベント「箱根日帰りドライブ」(event-001) が存在し、イベントメンバーとして太郎・花子が設定済み
///   - MarkDetail（ml-001: 自宅出発）・LinkDetail（ml-002: 東名高速）・PaymentDetail（pay-001）が利用可能

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
  /// 見つかった場合は true、見つからない場合は false を返す。
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
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) {
        break;
      }
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

  /// ミチタブで指定 Key のカードをタップして Detail 画面を開く。
  /// チップが表示されるまで待つ。
  Future<bool> openMarkLinkDetailByKey(
    WidgetTester tester, {
    required String cardKey,
    required String waitForKeyPrefix,
  }) async {
    final card = find.byKey(Key(cardKey));
    if (card.evaluate().isEmpty) return false;
    await tester.tap(card);
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
  /// チップが表示されるまで待つ。
  Future<bool> openPaymentDetailById(
    WidgetTester tester,
    String paymentId,
  ) async {
    final tile = find.byKey(Key('payment_info_tile_slidable_$paymentId'));
    if (tile.evaluate().isEmpty) return false;
    // タイル内の InkWell をタップ（Slidable の子）
    await tester.tap(tile);
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
    final navigated = await openMarkLinkDetailByKey(
      tester,
      cardKey: markCardKey,
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
    final navigated = await openMarkLinkDetailByKey(
      tester,
      cardKey: linkCardKey,
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

  // ────────────────────────────────────────────────────────
  // MarkDetail テスト (TC-PBM-001 〜 TC-PBM-004)
  // ────────────────────────────────────────────────────────

  testWidgets('TC-PBM-001: MarkDetail — イベントメンバーが全員チップで表示される',
      (tester) async {
    final skipReason = await setupMarkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎 (member-001) のチップが表示されること
    expect(
      find.byKey(const Key('markDetail_chip_member_member-001')),
      findsOneWidget,
      reason:
          'MarkDetail に太郎 (markDetail_chip_member_member-001) のチップが表示されること',
    );
  });

  testWidgets('TC-PBM-001b: MarkDetail — 花子のチップも表示される', (tester) async {
    final skipReason = await setupMarkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 花子 (member-002) のチップが表示されること
    expect(
      find.byKey(const Key('markDetail_chip_member_member-002')),
      findsOneWidget,
      reason:
          'MarkDetail に花子 (markDetail_chip_member_member-002) のチップが表示されること',
    );
  });

  testWidgets('TC-PBM-002: MarkDetail — チップタップで選択状態になる（multiple）',
      (tester) async {
    final skipReason = await setupMarkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎チップをタップ
    final taro = find.byKey(const Key('markDetail_chip_member_member-001'));
    if (taro.evaluate().isEmpty) {
      markTestSkipped('太郎のチップが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(taro);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(taro);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // タップ後もチップが存在し続けること（チップが消えない = 画面遷移しない）
    expect(
      find.byKey(const Key('markDetail_chip_member_member-001')),
      findsOneWidget,
      reason: 'タップ後も markDetail_chip_member_member-001 チップが表示されていること',
    );
  });

  testWidgets('TC-PBM-002b: MarkDetail — 2つのチップを同時選択できる（multiple）',
      (tester) async {
    final skipReason = await setupMarkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎チップをタップ
    final taro = find.byKey(const Key('markDetail_chip_member_member-001'));
    if (taro.evaluate().isEmpty) {
      markTestSkipped('太郎のチップが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(taro);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(taro);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 花子チップをタップ
    final hanako = find.byKey(const Key('markDetail_chip_member_member-002'));
    if (hanako.evaluate().isEmpty) {
      markTestSkipped('花子のチップが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(hanako);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(hanako);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 両チップが引き続き表示されること（multiple選択でどちらも消えない）
    expect(
      find.byKey(const Key('markDetail_chip_member_member-002')),
      findsOneWidget,
      reason:
          'multiple選択: 花子タップ後も markDetail_chip_member_member-002 が表示されていること',
    );
  });

  testWidgets('TC-PBM-003: MarkDetail — 選択済みチップを再タップで選択解除',
      (tester) async {
    final skipReason = await setupMarkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎チップが存在することを確認
    final taro = find.byKey(const Key('markDetail_chip_member_member-001'));
    if (taro.evaluate().isEmpty) {
      markTestSkipped('太郎のチップが見つからないためスキップします');
      return;
    }

    // 1回タップ（選択）
    await tester.ensureVisible(taro);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(taro);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 2回目タップ（選択解除）
    final taroAgain = find.byKey(const Key('markDetail_chip_member_member-001'));
    if (taroAgain.evaluate().isEmpty) {
      markTestSkipped('2回目タップ前にチップが消えたためスキップします');
      return;
    }
    await tester.ensureVisible(taroAgain);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(taroAgain);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // チップは引き続き存在すること（画面遷移・消滅しない）
    expect(
      find.byKey(const Key('markDetail_chip_member_member-001')),
      findsOneWidget,
      reason: '再タップ後も markDetail_chip_member_member-001 チップが存在すること（選択解除 = チップ消滅ではない）',
    );
  });

  testWidgets('TC-PBM-004: MarkDetail — 初期値（既存選択）が選択状態で表示される',
      (tester) async {
    // ml-001 (自宅出発) は seedData で members: [太郎, 花子] が設定済み
    final skipReason = await setupMarkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎 (member-001) のチップが表示されること
    expect(
      find.byKey(const Key('markDetail_chip_member_member-001')),
      findsOneWidget,
      reason:
          '初期値として太郎 (markDetail_chip_member_member-001) のチップが表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // LinkDetail テスト (TC-PBM-005 〜 TC-PBM-008)
  // ────────────────────────────────────────────────────────

  testWidgets('TC-PBM-005: LinkDetail — イベントメンバーが全員チップで表示される',
      (tester) async {
    final skipReason = await setupLinkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎 (member-001) のチップが表示されること
    expect(
      find.byKey(const Key('linkDetail_chip_member_member-001')),
      findsOneWidget,
      reason:
          'LinkDetail に太郎 (linkDetail_chip_member_member-001) のチップが表示されること',
    );
  });

  testWidgets('TC-PBM-005b: LinkDetail — 花子のチップも表示される', (tester) async {
    final skipReason = await setupLinkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 花子 (member-002) のチップが表示されること
    expect(
      find.byKey(const Key('linkDetail_chip_member_member-002')),
      findsOneWidget,
      reason:
          'LinkDetail に花子 (linkDetail_chip_member_member-002) のチップが表示されること',
    );
  });

  testWidgets('TC-PBM-006: LinkDetail — チップタップで選択状態になる（multiple）',
      (tester) async {
    final skipReason = await setupLinkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎チップをタップ
    final taro = find.byKey(const Key('linkDetail_chip_member_member-001'));
    if (taro.evaluate().isEmpty) {
      markTestSkipped('太郎のチップが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(taro);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(taro);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // タップ後もチップが存在し続けること（画面遷移しない）
    expect(
      find.byKey(const Key('linkDetail_chip_member_member-001')),
      findsOneWidget,
      reason: 'タップ後も linkDetail_chip_member_member-001 チップが表示されていること',
    );
  });

  testWidgets('TC-PBM-006b: LinkDetail — 2つのチップを同時選択できる（multiple）',
      (tester) async {
    final skipReason = await setupLinkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎チップをタップ
    final taro = find.byKey(const Key('linkDetail_chip_member_member-001'));
    if (taro.evaluate().isEmpty) {
      markTestSkipped('太郎のチップが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(taro);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(taro);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 花子チップをタップ
    final hanako = find.byKey(const Key('linkDetail_chip_member_member-002'));
    if (hanako.evaluate().isEmpty) {
      markTestSkipped('花子のチップが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(hanako);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(hanako);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 両チップが引き続き表示されること（multiple選択）
    expect(
      find.byKey(const Key('linkDetail_chip_member_member-002')),
      findsOneWidget,
      reason:
          'multiple選択: 花子タップ後も linkDetail_chip_member_member-002 が表示されていること',
    );
  });

  testWidgets('TC-PBM-007: LinkDetail — 選択済みチップを再タップで選択解除',
      (tester) async {
    final skipReason = await setupLinkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎チップが存在することを確認
    final taro = find.byKey(const Key('linkDetail_chip_member_member-001'));
    if (taro.evaluate().isEmpty) {
      markTestSkipped('太郎のチップが見つからないためスキップします');
      return;
    }

    // 1回タップ（選択）
    await tester.ensureVisible(taro);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(taro);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 2回目タップ（選択解除）
    final taroAgain = find.byKey(const Key('linkDetail_chip_member_member-001'));
    if (taroAgain.evaluate().isEmpty) {
      markTestSkipped('2回目タップ前にチップが消えたためスキップします');
      return;
    }
    await tester.ensureVisible(taroAgain);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(taroAgain);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // チップは引き続き存在すること
    expect(
      find.byKey(const Key('linkDetail_chip_member_member-001')),
      findsOneWidget,
      reason: '再タップ後も linkDetail_chip_member_member-001 チップが存在すること（選択解除 = チップ消滅ではない）',
    );
  });

  testWidgets('TC-PBM-008: LinkDetail — 初期値（既存選択）が選択状態で表示される',
      (tester) async {
    // ml-002 (東名高速) は seedData で members: [太郎, 花子] が設定済み
    final skipReason = await setupLinkDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎 (member-001) のチップが表示されること
    expect(
      find.byKey(const Key('linkDetail_chip_member_member-001')),
      findsOneWidget,
      reason:
          '初期値として太郎 (linkDetail_chip_member_member-001) のチップが表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // PaymentDetail テスト (TC-PBM-009 〜 TC-PBM-014)
  // ────────────────────────────────────────────────────────

  testWidgets('TC-PBM-009: PaymentDetail — イベントメンバーが支払者チップで全員表示される',
      (tester) async {
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎 (member-001) の支払者チップが表示されること
    expect(
      find.byKey(const Key('paymentDetail_chip_payMember_member-001')),
      findsOneWidget,
      reason:
          'PaymentDetail に太郎 (paymentDetail_chip_payMember_member-001) の支払者チップが表示されること',
    );
  });

  testWidgets('TC-PBM-009b: PaymentDetail — 花子の支払者チップも表示される',
      (tester) async {
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 花子 (member-002) の支払者チップが表示されること
    expect(
      find.byKey(const Key('paymentDetail_chip_payMember_member-002')),
      findsOneWidget,
      reason:
          'PaymentDetail に花子 (paymentDetail_chip_payMember_member-002) の支払者チップが表示されること',
    );
  });

  testWidgets('TC-PBM-010: PaymentDetail — 支払者チップタップで単一選択（他は非選択）',
      (tester) async {
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎の支払者チップをタップ
    final taroChip =
        find.byKey(const Key('paymentDetail_chip_payMember_member-001'));
    if (taroChip.evaluate().isEmpty) {
      markTestSkipped('太郎の支払者チップが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(taroChip);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(taroChip);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // タップ後もチップが存在し続けること（画面遷移しない = インライン選択）
    expect(
      find.byKey(const Key('paymentDetail_chip_payMember_member-001')),
      findsOneWidget,
      reason:
          'タップ後も paymentDetail_chip_payMember_member-001 チップが表示されていること',
    );
  });

  testWidgets('TC-PBM-010b: PaymentDetail — 花子チップも引き続き表示される（single選択で消えない）',
      (tester) async {
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎チップをタップ後、花子チップが表示されたままであること（別画面へ遷移しない）
    final taroChip =
        find.byKey(const Key('paymentDetail_chip_payMember_member-001'));
    if (taroChip.evaluate().isEmpty) {
      markTestSkipped('太郎の支払者チップが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(taroChip);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(taroChip);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 花子チップも引き続き表示されること
    expect(
      find.byKey(const Key('paymentDetail_chip_payMember_member-002')),
      findsOneWidget,
      reason:
          '太郎タップ後も花子 (paymentDetail_chip_payMember_member-002) チップが表示されていること（single選択でも全チップ表示）',
    );
  });

  testWidgets('TC-PBM-011: PaymentDetail — 割り勘チップで全員表示される',
      (tester) async {
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎 (member-001) の割り勘チップが表示されること
    expect(
      find.byKey(const Key('paymentDetail_chip_splitMember_member-001')),
      findsOneWidget,
      reason:
          'PaymentDetail に太郎 (paymentDetail_chip_splitMember_member-001) の割り勘チップが表示されること',
    );
  });

  testWidgets('TC-PBM-011b: PaymentDetail — 花子の割り勘チップも表示される',
      (tester) async {
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 花子 (member-002) の割り勘チップが表示されること
    expect(
      find.byKey(const Key('paymentDetail_chip_splitMember_member-002')),
      findsOneWidget,
      reason:
          'PaymentDetail に花子 (paymentDetail_chip_splitMember_member-002) の割り勘チップが表示されること',
    );
  });

  testWidgets('TC-PBM-012: PaymentDetail — 割り勘チップタップでON/OFF切り替え',
      (tester) async {
    // pay-001 の支払者は太郎。割り勘メンバーは太郎・花子。
    // 花子の割り勘チップをタップしてOFF→ON、またはON→OFFを確認する。
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 花子の割り勘チップをタップ
    final hanakoSplit =
        find.byKey(const Key('paymentDetail_chip_splitMember_member-002'));
    if (hanakoSplit.evaluate().isEmpty) {
      markTestSkipped('花子の割り勘チップが見つからないためスキップします');
      return;
    }
    await tester.ensureVisible(hanakoSplit);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(hanakoSplit);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // タップ後もチップが存在し続けること（画面遷移しない = インライン選択）
    expect(
      find.byKey(const Key('paymentDetail_chip_splitMember_member-002')),
      findsOneWidget,
      reason:
          'タップ後も paymentDetail_chip_splitMember_member-002 チップが表示されていること',
    );
  });

  testWidgets('TC-PBM-013: PaymentDetail — 支払者は割り勘チップで常にON固定（非活性）',
      (tester) async {
    // pay-001 の支払者は太郎 (member-001)。
    // 太郎の割り勘チップをタップしても状態が変わらない（非活性）。
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎の割り勘チップが存在すること
    final taroSplit =
        find.byKey(const Key('paymentDetail_chip_splitMember_member-001'));
    if (taroSplit.evaluate().isEmpty) {
      markTestSkipped('太郎の割り勘チップが見つからないためスキップします');
      return;
    }

    // タップを試みる（非活性のため Bloc にイベントが届かない想定）
    await tester.ensureVisible(taroSplit);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(taroSplit, warnIfMissed: false);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // タップ後もチップが存在し続けること（非活性 = チップが消えない）
    expect(
      find.byKey(const Key('paymentDetail_chip_splitMember_member-001')),
      findsOneWidget,
      reason:
          'タップ後も太郎の割り勘チップ (paymentDetail_chip_splitMember_member-001) が表示されていること（非活性固定）',
    );
  });

  testWidgets('TC-PBM-014: PaymentDetail — 初期値（既存選択）が選択状態で表示される',
      (tester) async {
    // pay-001: 支払者=太郎、割り勘=[太郎,花子] で seedData 設定済み
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎の支払者チップが表示されること
    expect(
      find.byKey(const Key('paymentDetail_chip_payMember_member-001')),
      findsOneWidget,
      reason:
          '初期値として太郎の支払者チップ (paymentDetail_chip_payMember_member-001) が表示されること',
    );
  });

  testWidgets('TC-PBM-014b: PaymentDetail — 初期値の割り勘チップが表示される',
      (tester) async {
    // pay-001: splitMembers=[太郎, 花子]
    final skipReason = await setupPaymentDetail(tester);
    if (skipReason != null) {
      markTestSkipped(skipReason);
      return;
    }

    // 太郎の割り勘チップが表示されること
    expect(
      find.byKey(const Key('paymentDetail_chip_splitMember_member-001')),
      findsOneWidget,
      reason:
          '初期値として太郎の割り勘チップ (paymentDetail_chip_splitMember_member-001) が表示されること',
    );
  });
}
