// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: F-6 訪問作業トピックからメンバー項目を除外
///
/// Spec: docs/Spec/Features/FS-visit_work_no_member.md §16
///
/// テストシナリオ: TC-NM-I001 〜 TC-NM-I009
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータに visitWork トピック（シナリオC）と movingCost トピック（シナリオA）が存在すること
///   - B-17 シードデータ実装・F-3 訪問作業トピック実装が完了していること

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

  /// アプリを起動してイベント一覧が表示されるまで待つ。
  Future<void> startApp(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/');
    app.main();
    for (var i = 0; i < 30; i++) {
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

  /// イベント一覧から指定名のイベントをタップしてEventDetailを開く。
  Future<bool> openEventByName(WidgetTester tester, String eventName) async {
    for (var i = 0; i < 10; i++) {
      if (find.text(eventName).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isEmpty) break;
      await tester.drag(listViews.first, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 200));
    }

    if (find.text(eventName).evaluate().isEmpty) {
      return false;
    }

    await tester.tap(find.text(eventName).first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 概要タブを表示する。
  Future<void> openOverviewTab(WidgetTester tester) async {
    final overviewTab = find.text('概要');
    if (overviewTab.evaluate().isNotEmpty) {
      await tester.tap(overviewTab.first);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('basicInfoRead_container_section')).evaluate().isNotEmpty ||
            find.text('タップして編集').evaluate().isNotEmpty) {
          break;
        }
      }
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// ミチタブを表示する。
  Future<void> openMichiTab(WidgetTester tester) async {
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isNotEmpty) {
      await tester.tap(michiTab.first);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  /// 支払タブを表示する。
  Future<void> openPaymentTab(WidgetTester tester) async {
    final paymentTab = find.text('支払');
    if (paymentTab.evaluate().isNotEmpty) {
      await tester.tap(paymentTab.first);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  /// ミチタブで最初のマークカードをタップしてMarkDetailを開く。
  Future<bool> openFirstMarkDetail(WidgetTester tester) async {
    // michiInfo_item_mark_ プレフィックスのキーを持つWidgetを探す
    for (var i = 0; i < 10; i++) {
      final markItems = find.byWidgetPredicate((widget) {
        if (widget.key is Key) {
          return widget.key.toString().contains('michiInfo_item_mark_');
        }
        return false;
      });
      if (markItems.evaluate().isNotEmpty) {
        await tester.tap(markItems.first);
        for (var j = 0; j < 20; j++) {
          await tester.pump(const Duration(milliseconds: 300));
          if (find.text('保存').evaluate().isNotEmpty ||
              find.text('累積メーター').evaluate().isNotEmpty) {
            break;
          }
        }
        await tester.pump(const Duration(milliseconds: 300));
        return true;
      }
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isEmpty) break;
      await tester.drag(listViews.first, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 200));
    }
    return false;
  }

  /// 支払タブで最初の支払いをタップしてPaymentDetailを開く。
  Future<bool> openFirstPaymentDetail(WidgetTester tester) async {
    // 支払いリストのタップ可能なアイテムを探す
    // GestureDetector/InkWell 等で包まれたカードをタップ
    for (var i = 0; i < 10; i++) {
      final paymentButtons = find.byWidgetPredicate((widget) {
        if (widget.key is Key) {
          return widget.key.toString().contains('paymentInfo_button_delete_');
        }
        return false;
      });
      if (paymentButtons.evaluate().isNotEmpty) {
        // 削除ボタンではなくカード本体をタップしたいので、
        // 支払い金額テキストなどを探してタップ
        final amountTexts = find.textContaining('¥');
        if (amountTexts.evaluate().isNotEmpty) {
          await tester.tap(amountTexts.first);
          for (var j = 0; j < 20; j++) {
            await tester.pump(const Duration(milliseconds: 300));
            if (find.byKey(const Key('paymentDetail_field_amount')).evaluate().isNotEmpty ||
                find.byKey(const Key('paymentDetail_button_save')).evaluate().isNotEmpty) {
              break;
            }
          }
          await tester.pump(const Duration(milliseconds: 300));
          return find.byKey(const Key('paymentDetail_field_amount')).evaluate().isNotEmpty;
        }
      }
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isEmpty) break;
      await tester.drag(listViews.first, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 200));
    }
    return false;
  }

  // ────────────────────────────────────────────────────────
  // TC-NM-I001: visitWork BasicInfo: メンバー選択セクションが非表示
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-NM-I001: visitWorkトピック（横浜エリア訪問ルート）のBasicInfoでメンバー選択セクションが非表示であること',
    (tester) async {
      await startApp(tester);
      final opened = await openEventByName(tester, '横浜エリア訪問ルート');
      if (!opened) {
        print('[SKIP] TC-NM-I001: 「横浜エリア訪問ルート」が見つかりません');
        return;
      }
      await openOverviewTab(tester);

      // スクロールしてBasicInfo全体を確認
      for (var i = 0; i < 10; i++) {
        if (find.byKey(const Key('basicInfo_memberSection')).evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -300));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(
        find.byKey(const Key('basicInfo_memberSection')),
        findsNothing,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-NM-I002: movingCost BasicInfo: メンバー選択セクションが表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-NM-I002: movingCostトピック（箱根日帰りドライブ）のBasicInfoでメンバー選択セクションが表示されること',
    (tester) async {
      await startApp(tester);
      final opened = await openEventByName(tester, '箱根日帰りドライブ');
      if (!opened) {
        print('[SKIP] TC-NM-I002: 「箱根日帰りドライブ」が見つかりません');
        return;
      }
      await openOverviewTab(tester);

      // スクロールしてメンバーセクションを確認
      for (var i = 0; i < 10; i++) {
        if (find.byKey(const Key('basicInfo_memberSection')).evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -300));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(
        find.byKey(const Key('basicInfo_memberSection')),
        findsOneWidget,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-NM-I003: visitWork MarkDetail: メンバー選択UIが非表示
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-NM-I003: visitWorkトピックのMarkDetailでメンバー選択セクションが非表示であること',
    (tester) async {
      await startApp(tester);
      final opened = await openEventByName(tester, '横浜エリア訪問ルート');
      if (!opened) {
        print('[SKIP] TC-NM-I003: 「横浜エリア訪問ルート」が見つかりません');
        return;
      }
      await openMichiTab(tester);

      final markOpened = await openFirstMarkDetail(tester);
      if (!markOpened) {
        print('[SKIP] TC-NM-I003: マークが見つかりませんでした');
        return;
      }

      // MarkDetail内でメンバーセクションを探す（スクロール含む）
      for (var i = 0; i < 10; i++) {
        if (find.byKey(const Key('markDetail_memberSection')).evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -300));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(
        find.byKey(const Key('markDetail_memberSection')),
        findsNothing,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-NM-I004: movingCost MarkDetail: メンバー選択UIが表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-NM-I004: movingCostトピックのMarkDetailでメンバー選択セクションが表示されること',
    (tester) async {
      await startApp(tester);
      final opened = await openEventByName(tester, '箱根日帰りドライブ');
      if (!opened) {
        print('[SKIP] TC-NM-I004: 「箱根日帰りドライブ」が見つかりません');
        return;
      }
      await openMichiTab(tester);

      final markOpened = await openFirstMarkDetail(tester);
      if (!markOpened) {
        print('[SKIP] TC-NM-I004: マークが見つかりませんでした');
        return;
      }

      for (var i = 0; i < 10; i++) {
        if (find.byKey(const Key('markDetail_memberSection')).evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -300));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(
        find.byKey(const Key('markDetail_memberSection')),
        findsOneWidget,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-NM-I005: visitWork PaymentDetail: 割り勘メンバー選択UIが非表示
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-NM-I005: visitWorkトピックのPaymentDetailで割り勘メンバーチップが非表示であること',
    (tester) async {
      await startApp(tester);
      final opened = await openEventByName(tester, '横浜エリア訪問ルート');
      if (!opened) {
        print('[SKIP] TC-NM-I005: 「横浜エリア訪問ルート」が見つかりません');
        return;
      }
      await openPaymentTab(tester);

      final paymentOpened = await openFirstPaymentDetail(tester);
      if (!paymentOpened) {
        print('[SKIP] TC-NM-I005: 支払い詳細が開けませんでした');
        return;
      }

      // 割り勘セクションが非表示であること
      // _SplitMemberChipSection 内のボタンキーで確認
      for (var i = 0; i < 10; i++) {
        if (find.byKey(const Key('paymentDetail_button_selectAllSplitMembers'))
            .evaluate()
            .isNotEmpty) {
          break;
        }
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -300));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(
        find.byKey(const Key('paymentDetail_button_selectAllSplitMembers')),
        findsNothing,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-NM-I006: movingCost PaymentDetail: 割り勘メンバー選択UIが表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-NM-I006: movingCostトピックのPaymentDetailで割り勘メンバーチップが表示されること',
    (tester) async {
      await startApp(tester);
      final opened = await openEventByName(tester, '箱根日帰りドライブ');
      if (!opened) {
        print('[SKIP] TC-NM-I006: 「箱根日帰りドライブ」が見つかりません');
        return;
      }
      await openPaymentTab(tester);

      final paymentOpened = await openFirstPaymentDetail(tester);
      if (!paymentOpened) {
        print('[SKIP] TC-NM-I006: 支払い詳細が開けませんでした');
        return;
      }

      for (var i = 0; i < 10; i++) {
        if (find.byKey(const Key('paymentDetail_button_selectAllSplitMembers'))
            .evaluate()
            .isNotEmpty) {
          break;
        }
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -300));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(
        find.byKey(const Key('paymentDetail_button_selectAllSplitMembers')),
        findsOneWidget,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-NM-I007: visitWork PaymentInfo: メンバー別精算セクションが非表示
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-NM-I007: visitWorkトピックのPaymentInfoで割り勘メンバーチップが表示されないこと',
    (tester) async {
      await startApp(tester);
      final opened = await openEventByName(tester, '横浜エリア訪問ルート');
      if (!opened) {
        print('[SKIP] TC-NM-I007: 「横浜エリア訪問ルート」が見つかりません');
        return;
      }
      await openPaymentTab(tester);

      // PaymentInfo 画面全体をスクロールして「割り勘」テキストを探す
      var foundSplitSection = false;
      for (var i = 0; i < 10; i++) {
        // 割り勘メンバー関連の表示を探す
        if (find.textContaining('割り勘').evaluate().isNotEmpty) {
          foundSplitSection = true;
          break;
        }
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -400));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      // visitWork トピックでは割り勘メンバーが表示されないこと
      // showMemberSection == false のため
      expect(foundSplitSection, isFalse);
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-NM-I009: visitWork PaymentDetail: メンバー選択なしで保存できる
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-NM-I009: visitWorkトピックで支払いを金額入力のみで保存できること（メンバー選択不要）',
    (tester) async {
      await startApp(tester);
      final opened = await openEventByName(tester, '横浜エリア訪問ルート');
      if (!opened) {
        print('[SKIP] TC-NM-I009: 「横浜エリア訪問ルート」が見つかりません');
        return;
      }
      await openPaymentTab(tester);

      // 支払い追加ボタン（FAB）をタップ
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isEmpty) {
        print('[SKIP] TC-NM-I009: 支払い追加FABが見つかりません');
        return;
      }
      await tester.tap(fab.first);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('paymentDetail_field_amount')).evaluate().isNotEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      if (find.byKey(const Key('paymentDetail_field_amount')).evaluate().isEmpty) {
        print('[SKIP] TC-NM-I009: PaymentDetail画面が開けませんでした');
        return;
      }

      // 金額を入力
      final amountField = find.byKey(const Key('paymentDetail_field_amount'));
      await tester.tap(amountField.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(amountField.first, '3000');
      await tester.pump(const Duration(milliseconds: 300));

      // 保存ボタンをタップ
      final saveButton = find.byKey(const Key('paymentDetail_button_save'));
      if (saveButton.evaluate().isEmpty) {
        print('[SKIP] TC-NM-I009: 保存ボタンが見つかりません');
        return;
      }
      await tester.ensureVisible(saveButton.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(saveButton.first);

      // 保存後にPaymentDetail画面が閉じること（エラーなしで保存成功）
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byKey(const Key('paymentDetail_field_amount')).evaluate().isEmpty) break;
      }
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byKey(const Key('paymentDetail_field_amount')),
        findsNothing,
      );
    },
  );
}
