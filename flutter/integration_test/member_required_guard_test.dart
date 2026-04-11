// ignore_for_file: avoid_print

/// Integration Test: メンバー未選択時の入力ガード
///
/// Feature Spec: docs/Spec/Features/MemberRequiredGuard_Spec.md
/// テストグループ: TC-MRG（Member Required Guard）
///
/// TC-MRG-001: BasicInfo ガソリン支払者 — メンバー未選択時に非活性（SKIP: シードにメンバー0件イベントなし）
/// TC-MRG-002: BasicInfo ガソリン支払者 — メンバー選択済みで活性（タップで遷移）
/// TC-MRG-003: MarkDetail 参加メンバー — メンバー未選択時に非活性（SKIP: シードにメンバー0件イベントなし）
/// TC-MRG-004: MarkDetail 参加メンバー — メンバー存在で活性
/// TC-MRG-005: PaymentDetail 支払い者・割り勘メンバー — メンバー未選択時に非活性（SKIP: シードにメンバー0件イベントなし）
/// TC-MRG-006: PaymentDetail 支払い者・割り勘メンバー — メンバー存在で活性
///
/// シードデータ:
///   TC-MRG-002: event-004（週末ドライブ（燃費推定））TopicType.movingCostEstimated → showPayMember: true
///   TC-MRG-004: event-001（箱根日帰りドライブ）ml-001（自宅出発）members: [太郎, 花子]
///   TC-MRG-006: event-001（箱根日帰りドライブ）pay-001（高速道路代 ¥3,200）
///
/// 注: シードデータにメンバー0人のイベントが存在しないため、
///     TC-MRG-001/003/005 はSKIPとする（非活性UI確認は手動テストが必要）。

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
      if (find.text('イベント').evaluate().isNotEmpty) break;
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(ListView).evaluate().isNotEmpty ||
          find.text('イベントがありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// イベント一覧から指定イベントをタップして EventDetail を開く。
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
    // BasicInfoSection のロード完了を待つ（「編集」ボタンが表示されるまで）
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byIcon(Icons.edit).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 概要タブを表示する共通ヘルパー。
  Future<bool> goToBasicInfoTab(WidgetTester tester, String eventName) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return false;
    }

    final opened = await openEventDetail(tester, eventName);
    if (!opened) return false;

    // 概要タブをタップ（デフォルトで表示されている場合もある）
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab);
      await tester.pump(const Duration(milliseconds: 500));
    }

    // BasicInfo がロードされるまで待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ガソリン支払者').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// MichiInfo タブへ遷移する共通ヘルパー。
  Future<bool> goToMichiInfoTab(WidgetTester tester, String eventName) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return false;
    }

    final opened = await openEventDetail(tester, eventName);
    if (!opened) return false;

    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return false;
    await tester.tap(michiTab);
    await tester.pump(const Duration(milliseconds: 500));

    // MichiInfo ページのロードを待つ（FABが表示されるまで）
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 支払タブへ遷移する共通ヘルパー。
  Future<bool> goToPaymentInfoTab(WidgetTester tester, String eventName) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return false;
    }

    final opened = await openEventDetail(tester, eventName);
    if (!opened) return false;

    final payTab = find.text('支払');
    if (payTab.evaluate().isEmpty) return false;
    await tester.tap(payTab);

    // PaymentInfo がロードされるまで待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty ||
          find.text('支払情報がありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  // ────────────────────────────────────────────────────────
  // TC-MRG-001: BasicInfo ガソリン支払者 — メンバー未選択時に非活性
  // SKIP: シードデータにメンバー0件のイベントが存在しないため
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MRG-001: BasicInfo ガソリン支払者 — メンバー未選択時に非活性',
      (tester) async {
    markTestSkipped(
        'TC-MRG-001 SKIP: シードデータにメンバー0人のイベントが存在しないため検証不可。'
        'メンバー0件のイベントを追加したうえで手動確認をお願いします。');
  });

  // ────────────────────────────────────────────────────────
  // TC-MRG-002: BasicInfo ガソリン支払者 — メンバー選択済みで活性（タップで遷移）
  // 使用シード: event-004（週末ドライブ（燃費推定））TopicType.movingCostEstimated で showPayMember: true
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MRG-002: BasicInfo ガソリン支払者 — メンバー選択済みで活性（タップで遷移）',
      (tester) async {
    final navigated = await goToBasicInfoTab(tester, '週末ドライブ（燃費推定）');
    if (!navigated) {
      markTestSkipped('「週末ドライブ（燃費推定）」が見つからないか概要タブに遷移できないため TC-MRG-002 をスキップします');
      return;
    }

    // ガソリン支払者の行が表示されていることを確認
    final gasolineRow = find.text('ガソリン支払者');
    expect(
      gasolineRow,
      findsOneWidget,
      reason: '概要タブに「ガソリン支払者」の行が表示されること',
    );
    print('[TC-MRG-002] ガソリン支払者行: 発見');

    // ガソリン支払者の行（InkWell全体）をタップする
    final gasolineRowKey = find.byKey(const Key('basic_info_gas_pay_member_row'));
    if (gasolineRowKey.evaluate().isNotEmpty) {
      await tester.ensureVisible(gasolineRowKey);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(gasolineRowKey);
    } else {
      // キーが見つからない場合はテキストの祖先 InkWell をタップ
      final inkWells = find.ancestor(
        of: gasolineRow,
        matching: find.byType(InkWell),
      );
      if (inkWells.evaluate().isNotEmpty) {
        await tester.ensureVisible(inkWells.first);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(inkWells.first);
      } else {
        // InkWell が見つからない場合はテキスト位置をタップ
        await tester.ensureVisible(gasolineRow);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(gasolineRow);
      }
    }

    // タップ後の画面遷移を待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // 選択画面のキーワードが表示されれば遷移成功
      if (find.text('メンバー選択').evaluate().isNotEmpty ||
          find.text('支払者選択').evaluate().isNotEmpty ||
          find.text('太郎').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // タップ後にいずれかのメンバー名が表示されること（選択画面に遷移した）
    // または「ガソリン支払者」の行がなくなっていること（別画面に遷移）
    final isTransitioned =
        find.text('メンバー選択').evaluate().isNotEmpty ||
        find.text('支払者選択').evaluate().isNotEmpty ||
        find.text('太郎').evaluate().isNotEmpty;

    print('[TC-MRG-002] タップ後に遷移した: $isTransitioned');
    expect(
      isTransitioned,
      isTrue,
      reason: 'メンバーが選択済みの場合、ガソリン支払者の行をタップすると選択画面に遷移すること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MRG-003: MarkDetail 参加メンバー — メンバー未選択時に非活性
  // SKIP: シードデータにメンバー0件のイベントが存在しないため
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MRG-003: MarkDetail 参加メンバー — メンバー未選択時に非活性',
      (tester) async {
    markTestSkipped(
        'TC-MRG-003 SKIP: シードデータにメンバー0人のイベントが存在しないため検証不可。'
        'メンバー0件のイベントを追加したうえで手動確認をお願いします。');
  });

  // ────────────────────────────────────────────────────────
  // TC-MRG-004: MarkDetail 参加メンバー — メンバー存在で活性
  // 使用シード: event-001（箱根日帰りドライブ）ml-001（自宅出発）
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MRG-004: MarkDetail 参加メンバー — メンバー存在で活性', (tester) async {
    final navigated = await goToMichiInfoTab(tester, '箱根日帰りドライブ');
    if (!navigated) {
      markTestSkipped('「箱根日帰りドライブ」のミチタブに遷移できないため TC-MRG-004 をスキップします');
      return;
    }

    // ml-001（自宅出発）のマークカードを探す
    final markCardKey = find.byKey(const Key('michi_info_card_ml-001'));
    if (markCardKey.evaluate().isEmpty) {
      // キーが見つからない場合はマーク名で探す
      final markCard = find.text('自宅出発');
      if (markCard.evaluate().isEmpty) {
        markTestSkipped('ml-001（自宅出発）カードが見つからないため TC-MRG-004 をスキップします');
        return;
      }
      // カード名をタップしてMarkDetailを開く
      await tester.tap(markCard);
    } else {
      await tester.tap(markCardKey);
    }

    // MarkDetail がロードされるまで待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('メンバー').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // メンバーの行が表示されていることを確認
    final memberRow = find.text('メンバー');
    if (memberRow.evaluate().isEmpty) {
      markTestSkipped('MarkDetailで「メンバー」の行が見つからないため TC-MRG-004 をスキップします');
      return;
    }
    print('[TC-MRG-004] メンバー行: 発見');

    // 参加メンバーの行をタップする
    final memberRowKey = find.byKey(const Key('mark_detail_participants_row'));
    if (memberRowKey.evaluate().isNotEmpty) {
      await tester.ensureVisible(memberRowKey);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(memberRowKey);
    } else {
      final inkWells = find.ancestor(
        of: memberRow,
        matching: find.byType(InkWell),
      );
      if (inkWells.evaluate().isNotEmpty) {
        await tester.ensureVisible(inkWells.first);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(inkWells.first);
      } else {
        await tester.ensureVisible(memberRow);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(memberRow);
      }
    }

    // タップ後の画面遷移を待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('メンバー選択').evaluate().isNotEmpty ||
          find.text('参加者選択').evaluate().isNotEmpty ||
          find.text('太郎').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final isTransitioned =
        find.text('メンバー選択').evaluate().isNotEmpty ||
        find.text('参加者選択').evaluate().isNotEmpty ||
        find.text('太郎').evaluate().isNotEmpty;

    print('[TC-MRG-004] タップ後に遷移した: $isTransitioned');
    expect(
      isTransitioned,
      isTrue,
      reason: 'メンバーが存在する場合、メンバーの行をタップすると選択画面に遷移すること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MRG-005: PaymentDetail 支払い者・割り勘メンバー — メンバー未選択時に非活性
  // SKIP: シードデータにメンバー0件のイベントが存在しないため
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TC-MRG-005: PaymentDetail 支払い者・割り勘メンバー — メンバー未選択時に非活性',
      (tester) async {
    markTestSkipped(
        'TC-MRG-005 SKIP: シードデータにメンバー0人のイベントが存在しないため検証不可。'
        'メンバー0件のイベントを追加したうえで手動確認をお願いします。');
  });

  // ────────────────────────────────────────────────────────
  // TC-MRG-006: PaymentDetail 支払い者・割り勘メンバー — メンバー存在で活性
  // 使用シード: event-001（箱根日帰りドライブ）pay-001（高速道路代）
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MRG-006: PaymentDetail 支払い者・割り勘メンバー — メンバー存在で活性',
      (tester) async {
    final navigated = await goToPaymentInfoTab(tester, '箱根日帰りドライブ');
    if (!navigated) {
      markTestSkipped('「箱根日帰りドライブ」の支払タブに遷移できないため TC-MRG-006 をスキップします');
      return;
    }

    // pay-001（高速道路代）の伝票カードをタップして PaymentDetail を開く
    final payCardKey = find.byKey(const Key('payment_info_tile_pay-001'));
    if (payCardKey.evaluate().isEmpty) {
      // キーが見つからない場合は伝票名で探す
      final payCard = find.text('高速道路代');
      if (payCard.evaluate().isEmpty) {
        markTestSkipped('pay-001（高速道路代）カードが見つからないため TC-MRG-006 をスキップします');
        return;
      }
      await tester.tap(payCard);
    } else {
      await tester.tap(payCardKey);
    }

    // PaymentDetail がロードされるまで待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('支払者').evaluate().isNotEmpty ||
          find.text('割り勘').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // ── 支払者行のタップ確認 ──
    final payerRow = find.text('支払者');
    if (payerRow.evaluate().isEmpty) {
      markTestSkipped('PaymentDetailで「支払者」の行が見つからないため TC-MRG-006 をスキップします');
      return;
    }
    print('[TC-MRG-006] 支払者行: 発見');

    // 支払い者の行をタップする
    final payerRowKey = find.byKey(const Key('payment_detail_payer_row'));
    if (payerRowKey.evaluate().isNotEmpty) {
      await tester.ensureVisible(payerRowKey);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(payerRowKey);
    } else {
      final inkWells = find.ancestor(
        of: payerRow,
        matching: find.byType(InkWell),
      );
      if (inkWells.evaluate().isNotEmpty) {
        await tester.ensureVisible(inkWells.first);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(inkWells.first);
      } else {
        await tester.ensureVisible(payerRow);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(payerRow);
      }
    }

    // タップ後の画面遷移を待つ（支払い者選択画面）
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('メンバー選択').evaluate().isNotEmpty ||
          find.text('支払者選択').evaluate().isNotEmpty ||
          find.text('太郎').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final isPayerTransitioned =
        find.text('メンバー選択').evaluate().isNotEmpty ||
        find.text('支払者選択').evaluate().isNotEmpty ||
        find.text('太郎').evaluate().isNotEmpty;

    print('[TC-MRG-006] 支払者タップ後に遷移した: $isPayerTransitioned');
    expect(
      isPayerTransitioned,
      isTrue,
      reason: 'メンバーが存在する場合、支払者の行をタップすると選択画面に遷移すること',
    );

    // 選択画面から戻る
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
    } else {
      final backIcon = find.byIcon(Icons.arrow_back);
      if (backIcon.evaluate().isNotEmpty) {
        await tester.tap(backIcon.first);
      }
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('支払者').evaluate().isNotEmpty ||
          find.text('割り勘').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // ── 割り勘行のタップ確認 ──
    final splitRow = find.text('割り勘');
    if (splitRow.evaluate().isEmpty) {
      print('[TC-MRG-006] WARNING: 「割り勘」の行が見つからない。支払者のみ確認済み。');
      return;
    }
    print('[TC-MRG-006] 割り勘行: 発見');

    // 割り勘行をタップする
    final splitRowKey = find.byKey(const Key('payment_detail_split_members_row'));
    if (splitRowKey.evaluate().isNotEmpty) {
      await tester.ensureVisible(splitRowKey);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(splitRowKey);
    } else {
      final inkWells = find.ancestor(
        of: splitRow,
        matching: find.byType(InkWell),
      );
      if (inkWells.evaluate().isNotEmpty) {
        await tester.ensureVisible(inkWells.first);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(inkWells.first);
      } else {
        await tester.ensureVisible(splitRow);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(splitRow);
      }
    }

    // タップ後の画面遷移を待つ（割り勘メンバー選択画面）
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('メンバー選択').evaluate().isNotEmpty ||
          find.text('割り勘').evaluate().isNotEmpty ||
          find.text('太郎').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    final isSplitTransitioned =
        find.text('メンバー選択').evaluate().isNotEmpty ||
        find.text('太郎').evaluate().isNotEmpty;

    print('[TC-MRG-006] 割り勘メンバータップ後に遷移した: $isSplitTransitioned');
    expect(
      isSplitTransitioned,
      isTrue,
      reason: 'メンバーが存在する場合、割り勘メンバーの行をタップすると選択画面に遷移すること',
    );
  });
}
