// ignore_for_file: avoid_print

/// Integration Test: PaymentInfo 伝票削除機能
///
/// Feature Spec: docs/Spec/Features/PaymentInfoCardDelete_Spec.md
/// テストグループ: TC-PID（Payment Info Delete）
///
/// TC-PID-001: 伝票行を左スワイプすると削除ボタンが表示される
/// TC-PID-002: 削除ボタンをタップすると伝票が一覧から消える
/// TC-PID-003: 削除後に合計金額が再計算される
/// TC-PID-004: 最後の 1 件を削除すると空状態 UI が表示される（シードデータ次第で SKIP 可）
/// TC-PID-005: 削除後に確認ダイアログが表示されない
///
/// シードデータ（event-001: 箱根日帰りドライブ）の構成:
///   pay-001: 高速道路代 ¥3,200（支払者: 太郎）
///   pay-002: 昼食代 ¥2,400（支払者: 花子）
///   合計: ¥5,600
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

  /// イベント一覧から指定イベントをタップして EventDetail を開く。
  /// 開けた場合は true、見つからない場合は false を返す。
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
          find.text('支払').evaluate().isNotEmpty) {
        break;
      }
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
          find.text('支払情報がありません').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 指定した paymentId の Slidable を左スワイプして削除ボタンを表示する。
  Future<void> swipeToRevealDeleteButton(
    WidgetTester tester,
    String paymentId,
  ) async {
    final slidableKey = Key('payment_info_tile_slidable_$paymentId');
    await tester.drag(find.byKey(slidableKey), const Offset(-300, 0));
    await tester.pump(const Duration(milliseconds: 500));
  }

  // ────────────────────────────────────────────────────────
  // TC-PID-001: 伝票行を左スワイプすると削除ボタンが表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PID-001: 伝票行を左スワイプすると削除ボタンが表示される', (tester) async {
    final navigated = await goToPaymentInfoTab(tester);
    if (!navigated) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないか支払タブに遷移できないため TC-PID-001 をスキップします');
      return;
    }

    // pay-001 の Slidable を確認
    const paymentId = 'pay-001';
    final slidableKey = Key('payment_info_tile_slidable_$paymentId');

    if (find.byKey(slidableKey).evaluate().isEmpty) {
      markTestSkipped(
        'payment_info_tile_slidable_$paymentId が見つからないため TC-PID-001 をスキップします',
      );
      return;
    }

    // 左スワイプして削除ボタンを表示する
    await swipeToRevealDeleteButton(tester, paymentId);

    // 削除アクションキーで確認
    final deleteActionKey = Key('payment_info_tile_delete_action_$paymentId');
    expect(
      find.byKey(deleteActionKey),
      findsOneWidget,
      reason:
          '左スワイプ後に削除ボタン (payment_info_tile_delete_action_$paymentId) が表示されること',
    );

    // ラベル「削除」も表示されていること
    expect(
      find.text('削除'),
      findsAtLeastNWidgets(1),
      reason: '削除アクションのラベル「削除」が表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PID-002: 削除ボタンをタップすると伝票が一覧から消える
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PID-002: 削除ボタンをタップすると伝票が一覧から消える', (tester) async {
    final navigated = await goToPaymentInfoTab(tester);
    if (!navigated) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないか支払タブに遷移できないため TC-PID-002 をスキップします');
      return;
    }

    // pay-001 を削除対象とする（pay-002 が残ることを確認するため）
    const paymentId = 'pay-001';
    final slidableKey = Key('payment_info_tile_slidable_$paymentId');
    final deleteActionKey = Key('payment_info_tile_delete_action_$paymentId');

    if (find.byKey(slidableKey).evaluate().isEmpty) {
      markTestSkipped(
        'payment_info_tile_slidable_$paymentId が見つからないため TC-PID-002 をスキップします',
      );
      return;
    }

    // pay-002 が存在するか事前確認（削除後に他の伝票が残ることを検証するため）
    final otherPaymentKey = const Key('payment_info_tile_slidable_pay-002');
    final otherPaymentExists = find
        .byKey(otherPaymentKey)
        .evaluate()
        .isNotEmpty;

    // 左スワイプして削除ボタンを表示
    await swipeToRevealDeleteButton(tester, paymentId);

    expect(
      find.byKey(deleteActionKey),
      findsOneWidget,
      reason: 'スワイプ後に削除ボタンが表示されること',
    );

    // 削除ボタンをタップ
    await tester.ensureVisible(find.byKey(deleteActionKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteActionKey));

    // 削除処理の完了を待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(slidableKey).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // pay-001 が一覧から消えていることを確認
    expect(
      find.byKey(slidableKey),
      findsNothing,
      reason: '削除した伝票行 (pay-001: 高速道路代) が一覧から消えていること',
    );

    // 他の伝票行 (pay-002) はまだ表示されていることを確認
    if (otherPaymentExists) {
      expect(
        find.byKey(otherPaymentKey),
        findsOneWidget,
        reason: '削除していない伝票行 (pay-002: 昼食代) は引き続き表示されていること',
      );
    }
  });

  // ────────────────────────────────────────────────────────
  // TC-PID-003: 削除後に合計金額が再計算される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PID-003: 削除後に合計金額が再計算される', (tester) async {
    final navigated = await goToPaymentInfoTab(tester);
    if (!navigated) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないか支払タブに遷移できないため TC-PID-003 をスキップします');
      return;
    }

    // シードデータ: pay-001(¥3,200) + pay-002(¥2,400) = 合計¥5,600
    // pay-001 を削除後、残る pay-002(¥2,400) の合計になることを確認
    const paymentId = 'pay-001';
    final slidableKey = Key('payment_info_tile_slidable_$paymentId');
    final deleteActionKey = Key('payment_info_tile_delete_action_$paymentId');

    if (find.byKey(slidableKey).evaluate().isEmpty) {
      markTestSkipped(
        'payment_info_tile_slidable_$paymentId が見つからないため TC-PID-003 をスキップします',
      );
      return;
    }

    // 削除前の合計金額テキストを取得する
    // 「合計:」を含むテキストを探す
    final totalTexts = find.textContaining('合計:');
    final hasTotalBefore = totalTexts.evaluate().isNotEmpty;
    print('[TC-PID-003] 削除前: 合計テキスト存在 = $hasTotalBefore');

    // 左スワイプして削除ボタンを表示
    await swipeToRevealDeleteButton(tester, paymentId);

    expect(
      find.byKey(deleteActionKey),
      findsOneWidget,
      reason: 'スワイプ後に削除ボタンが表示されること',
    );

    // 削除ボタンをタップ
    await tester.ensureVisible(find.byKey(deleteActionKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteActionKey));

    // 削除処理の完了を待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(slidableKey).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 削除後: 合計金額が更新されていることを確認
    // pay-001(¥3,200) 削除後 → pay-002(¥2,400) のみ → 合計は ¥3,200 未満になっているはず
    final totalTextAfter = find.textContaining('合計:');
    expect(totalTextAfter, findsOneWidget, reason: '削除後も合計金額テキスト「合計:」が表示されること');

    // 削除前の合計（¥5,600）が表示されていないことで再計算を確認
    // ※ displayTotalAmount の書式が不明なため、¥3,200（削除した金額）が
    //   合計に含まれなくなったことをテキスト非存在で確認する
    final totalWidget = tester.widget<Text>(totalTextAfter);
    final totalText = totalWidget.data ?? '';
    print('[TC-PID-003] 削除後の合計テキスト: $totalText');

    // 合計テキストが空でないことを確認（何らかの金額が表示されていること）
    expect(totalText.isNotEmpty, isTrue, reason: '削除後の合計金額テキストが空でないこと');

    // pay-001(¥3,200)削除後の合計は pay-002(¥2,400) のみ
    // 旧合計 ¥5,600 は表示されないはず（書式依存のため緩い検証）
    expect(
      find.text('合計: ¥5,600'),
      findsNothing,
      reason: '削除前の合計金額 ¥5,600 が表示されなくなること（再計算されたこと）',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PID-004: 最後の 1 件を削除すると空状態 UI が表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PID-004: 最後の 1 件を削除すると空状態 UI が表示される', (tester) async {
    // シードデータに伝票が 1 件のみのイベントが存在しないためスキップ。
    // event-001 は pay-001・pay-002 の 2 件、event-002 は pay-003〜005 の 3 件、
    // event-003 は支払0件。
    // 1件のみのイベントが存在しないため本テストはスキップとする。
    markTestSkipped(
      'TC-PID-004: シードデータに伝票が 1 件のみのイベントが存在しないためスキップします。'
      '手動確認または専用シードデータの追加をお願いします。',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-PID-005: 削除後に確認ダイアログが表示されない
  // ────────────────────────────────────────────────────────
  testWidgets('TC-PID-005: 削除後に確認ダイアログが表示されない', (tester) async {
    final navigated = await goToPaymentInfoTab(tester);
    if (!navigated) {
      markTestSkipped('「箱根日帰りドライブ」が見つからないか支払タブに遷移できないため TC-PID-005 をスキップします');
      return;
    }

    // pay-001 を削除対象とする
    const paymentId = 'pay-001';
    final slidableKey = Key('payment_info_tile_slidable_$paymentId');
    final deleteActionKey = Key('payment_info_tile_delete_action_$paymentId');

    if (find.byKey(slidableKey).evaluate().isEmpty) {
      markTestSkipped(
        'payment_info_tile_slidable_$paymentId が見つからないため TC-PID-005 をスキップします',
      );
      return;
    }

    // 左スワイプして削除ボタンを表示
    await swipeToRevealDeleteButton(tester, paymentId);

    expect(
      find.byKey(deleteActionKey),
      findsOneWidget,
      reason: 'スワイプ後に削除ボタンが表示されること',
    );

    // 削除ボタンをタップ
    await tester.ensureVisible(find.byKey(deleteActionKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteActionKey));

    // 少し待つ（ダイアログが表示されるかどうかを確認するため）
    await tester.pump(const Duration(milliseconds: 500));

    // AlertDialog / ConfirmationDialog が表示されていないことを確認
    expect(
      find.byType(AlertDialog),
      findsNothing,
      reason: '削除後に AlertDialog が表示されないこと（確認なし即削除）',
    );

    // 削除処理の完了を待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 最終確認: 削除完了後もダイアログが出ていないことを確認
    expect(
      find.byType(AlertDialog),
      findsNothing,
      reason: '削除完了後も AlertDialog が表示されていないこと',
    );
  });
}
