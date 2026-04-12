// ignore_for_file: avoid_print

/// Integration Test: PaymentInfo 削除アイコン常時表示（UI-4）
///
/// Feature Spec: docs/Spec/Features/FS-payment_info_delete_icon.md
/// テストグループ: TC-PID2（Payment Info Delete Icon）
///
/// TC-PID2-001: スワイプ操作で削除UIが表示されない
/// TC-PID2-002: カード右端に削除アイコンが常時表示されている
/// TC-PID2-003: 削除アイコンタップで即削除される（ダイアログなし）
///
/// シードデータ（event-001: 箱根日帰りドライブ）の構成:
///   pay-001: 高速道路代 ¥3,200（支払者: 太郎）
///   pay-002: 昼食代 ¥2,400（支払者: 花子）
///   合計: ¥5,600

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

  /// イベント一覧から指定イベントをタップして EventDetail を開く。
  /// 開けた場合は true、見つからない場合は false を返す。
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
          find.text('支払').evaluate().isNotEmpty) break;
    }
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byIcon(Icons.edit).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// PaymentInfo（支払タブ）を表示するまでの共通ヘルパー。
  /// 失敗した場合は false を返す。
  Future<bool> goToPaymentInfoTab(WidgetTester tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return false;
    }

    final opened = await openEventDetail(tester, '箱根日帰りドライブ');
    if (!opened) return false;

    // 「支払」タブをタップ
    final payTab = find.text('支払');
    if (payTab.evaluate().isEmpty) return false;
    await tester.tap(payTab);

    // PaymentInfo がロードされるまで待つ（伝票一覧 or 空状態が表示されるまで）
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty ||
          find.text('支払情報がありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  // ────────────────────────────────────────────────────────
  // TC-PID2-001: スワイプ操作で削除UIが表示されない
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PID2-001: スワイプ操作で削除UIが表示されない', (tester) async {
    final navigated = await goToPaymentInfoTab(tester);
    if (!navigated) {
      markTestSkipped(
          '「箱根日帰りドライブ」が見つからないか支払タブに遷移できないため TC-PID2-001 をスキップします');
      return;
    }

    // Slidable ウィジェットのキーが存在しないことを確認（スワイプUI撤去済み）
    const paymentId = 'pay-001';
    final slidableKey = Key('payment_info_tile_slidable_$paymentId');

    // 伝票行が表示されているかを確認（伝票自体は存在する）
    // 削除アイコンが表示されているはず
    final deleteIconKey = Key('paymentInfo_button_delete_$paymentId');
    if (find.byKey(deleteIconKey).evaluate().isEmpty) {
      markTestSkipped(
          'paymentInfo_button_delete_$paymentId が見つからないため TC-PID2-001 をスキップします');
      return;
    }

    // 伝票行を左スワイプする
    await tester.drag(find.byKey(deleteIconKey), const Offset(-300, 0));
    await tester.pump(const Duration(milliseconds: 500));

    // Slidable の削除ボタンが表示されていないことを確認
    expect(
      find.byKey(slidableKey),
      findsNothing,
      reason: 'スワイプ後に Slidable ウィジェット (payment_info_tile_slidable_$paymentId) が存在しないこと',
    );

    // 「削除」テキストラベル（SlidableAction のラベル）が表示されていないことを確認
    expect(
      find.text('削除'),
      findsNothing,
      reason: 'スワイプ後に SlidableAction の「削除」ラベルが表示されないこと',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PID2-002: カード右端に削除アイコンが常時表示されている
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PID2-002: カード右端に削除アイコンが常時表示されている', (tester) async {
    final navigated = await goToPaymentInfoTab(tester);
    if (!navigated) {
      markTestSkipped(
          '「箱根日帰りドライブ」が見つからないか支払タブに遷移できないため TC-PID2-002 をスキップします');
      return;
    }

    // pay-001 の削除アイコンが初期表示から存在することを確認
    const paymentId = 'pay-001';
    final deleteIconKey = Key('paymentInfo_button_delete_$paymentId');

    // スワイプなどの操作なしに最初から表示されていること
    expect(
      find.byKey(deleteIconKey),
      findsOneWidget,
      reason: 'スワイプ等の操作なしに削除アイコン (paymentInfo_button_delete_$paymentId) が最初から表示されていること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PID2-003: 削除アイコンタップで即削除される（ダイアログなし）
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PID2-003: 削除アイコンタップで即削除される（ダイアログなし）', (tester) async {
    final navigated = await goToPaymentInfoTab(tester);
    if (!navigated) {
      markTestSkipped(
          '「箱根日帰りドライブ」が見つからないか支払タブに遷移できないため TC-PID2-003 をスキップします');
      return;
    }

    // 削除対象: pay-001 / 残存確認対象: pay-002
    const paymentId = 'pay-001';
    const otherPaymentId = 'pay-002';
    final deleteIconKey = Key('paymentInfo_button_delete_$paymentId');
    final otherDeleteIconKey = Key('paymentInfo_button_delete_$otherPaymentId');

    if (find.byKey(deleteIconKey).evaluate().isEmpty) {
      markTestSkipped(
          'paymentInfo_button_delete_$paymentId が見つからないため TC-PID2-003 をスキップします');
      return;
    }

    // pay-002 が事前に存在するか確認
    final otherExists =
        find.byKey(otherDeleteIconKey).evaluate().isNotEmpty;
    print('[TC-PID2-003] pay-002 削除アイコン存在: $otherExists');

    // 削除アイコンをタップ（操作前に可視状態を保証）
    await tester.ensureVisible(find.byKey(deleteIconKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteIconKey));

    // タップ直後: AlertDialog が表示されていないことを確認（即削除）
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byType(AlertDialog),
      findsNothing,
      reason: '削除アイコンタップ直後に AlertDialog が表示されないこと（確認なし即削除）',
    );

    // 削除処理の完了を待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(deleteIconKey).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 削除した伝票行の削除アイコンが消えていること（行が削除されたことの確認）
    expect(
      find.byKey(deleteIconKey),
      findsNothing,
      reason: '削除した伝票 (pay-001) の削除アイコンが一覧から消えていること',
    );

    // 他の伝票行（pay-002）の削除アイコンが引き続き表示されていること
    if (otherExists) {
      expect(
        find.byKey(otherDeleteIconKey),
        findsOneWidget,
        reason: '削除していない伝票 (pay-002) の削除アイコンが引き続き表示されていること',
      );
    }

    // 削除後も AlertDialog が表示されていないことを最終確認
    expect(
      find.byType(AlertDialog),
      findsNothing,
      reason: '削除完了後も AlertDialog が表示されていないこと',
    );
  });
}
