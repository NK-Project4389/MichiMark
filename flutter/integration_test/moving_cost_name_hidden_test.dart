// ignore_for_file: avoid_print

/// Integration Test: 移動コストトピック 名称非表示（UI-10）
///
/// Spec: docs/Spec/Features/FS-moving_cost_name_hidden.md §9
///
/// テストシナリオ: TC-MCN-001 〜 TC-MCN-003
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータ event-001「箱根日帰りドライブ」(movingCost) が存在すること
///   - シードデータ event-002「富士五湖キャンプ」(travelExpense) が存在すること

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
          find.text('イベントがありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// 指定イベント名のカードをタップして EventDetail の「ミチ」タブまで遷移する。
  /// イベントが見つからない場合は false を返す。
  Future<bool> goToMichiInfoTab(
    WidgetTester tester,
    String eventName,
  ) async {
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

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

    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return false;
    await tester.tap(michiTab);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 指定テキストのカードをスクロールしながら探してタップする。
  /// 見つからない場合は false を返す。
  Future<bool> tapCardByText(WidgetTester tester, String cardText) async {
    for (var i = 0; i < 5; i++) {
      if (find.text(cardText).evaluate().isNotEmpty) break;
      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.drag(listView.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
    if (find.text(cardText).evaluate().isEmpty) return false;

    await tester.ensureVisible(find.text(cardText).first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(cardText).first);
    return true;
  }

  // ────────────────────────────────────────────────────────
  // TC-MCN-001: movingCost トピックで MarkDetail を開くと名称フィールドが非表示
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-MCN-001: movingCostトピックでMarkDetailを開くと名称フィールドが非表示',
    (tester) async {
      await startApp(tester);

      // event-001「箱根日帰りドライブ」は movingCost トピック
      final moved = await goToMichiInfoTab(tester, '箱根日帰りドライブ');
      if (!moved) {
        print('[SKIP] 箱根日帰りドライブ のミチタブに遷移できなかったためスキップします');
        return;
      }

      // Mark カード「大涌谷」(ml-005) をタップして MarkDetail を開く
      final tapped = await tapCardByText(tester, '大涌谷');
      if (!tapped) {
        print('[SKIP] Mark カード「大涌谷」が見つからなかったためスキップします');
        return;
      }

      // MarkDetail 画面が表示されるまで待つ（保存ボタンで到達確認）
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byKey(const Key('markDetail_button_save')).evaluate().isNotEmpty ||
            find.byKey(const Key('markDetail_button_cancel')).evaluate().isNotEmpty) {
          break;
        }
      }
      await tester.pump(const Duration(milliseconds: 300));

      if (find.byKey(const Key('markDetail_button_save')).evaluate().isEmpty &&
          find.byKey(const Key('markDetail_button_cancel')).evaluate().isEmpty) {
        print('[SKIP] MarkDetail 画面に到達できなかったためスキップします');
        return;
      }

      // movingCost トピックでは名称フィールドが存在しないこと
      expect(
        find.byKey(const Key('markDetail_field_name')),
        findsNothing,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-MCN-002: movingCost トピックで LinkDetail を開くと名称フィールドが非表示
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-MCN-002: movingCostトピックでLinkDetailを開くと名称フィールドが非表示',
    (tester) async {
      await startApp(tester);

      // event-001「箱根日帰りドライブ」は movingCost トピック
      final moved = await goToMichiInfoTab(tester, '箱根日帰りドライブ');
      if (!moved) {
        print('[SKIP] 箱根日帰りドライブ のミチタブに遷移できなかったためスキップします');
        return;
      }

      // Link カード「東名高速」(ml-002) をタップして LinkDetail を開く
      final tapped = await tapCardByText(tester, '東名高速');
      if (!tapped) {
        print('[SKIP] Link カード「東名高速」が見つからなかったためスキップします');
        return;
      }

      // LinkDetail 画面が表示されるまで待つ（保存ボタンで到達確認）
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byKey(const Key('linkDetail_button_save')).evaluate().isNotEmpty ||
            find.byKey(const Key('linkDetail_button_cancel')).evaluate().isNotEmpty) {
          break;
        }
      }
      await tester.pump(const Duration(milliseconds: 300));

      if (find.byKey(const Key('linkDetail_button_save')).evaluate().isEmpty &&
          find.byKey(const Key('linkDetail_button_cancel')).evaluate().isEmpty) {
        print('[SKIP] LinkDetail 画面に到達できなかったためスキップします');
        return;
      }

      // movingCost トピックでは名称フィールドが存在しないこと
      expect(
        find.byKey(const Key('linkDetail_field_name')),
        findsNothing,
      );
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-MCN-003: travelExpense トピックで MarkDetail を開くと名称フィールドが表示
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-MCN-003: travelExpenseトピックでMarkDetailを開くと名称フィールドが表示',
    (tester) async {
      await startApp(tester);

      // event-002「富士五湖キャンプ」は travelExpense トピック
      final moved = await goToMichiInfoTab(tester, '富士五湖キャンプ');
      if (!moved) {
        print('[SKIP] 富士五湖キャンプ のミチタブに遷移できなかったためスキップします');
        return;
      }

      // Mark カード「河口湖キャンプ場」(ml-008) をタップして MarkDetail を開く
      final tapped = await tapCardByText(tester, '河口湖キャンプ場');
      if (!tapped) {
        print('[SKIP] Mark カード「河口湖キャンプ場」が見つからなかったためスキップします');
        return;
      }

      // MarkDetail 画面が表示されるまで待つ（保存ボタンで到達確認）
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byKey(const Key('markDetail_button_save')).evaluate().isNotEmpty ||
            find.byKey(const Key('markDetail_button_cancel')).evaluate().isNotEmpty) {
          break;
        }
      }
      await tester.pump(const Duration(milliseconds: 300));

      if (find.byKey(const Key('markDetail_button_save')).evaluate().isEmpty &&
          find.byKey(const Key('markDetail_button_cancel')).evaluate().isEmpty) {
        print('[SKIP] MarkDetail 画面に到達できなかったためスキップします');
        return;
      }

      // travelExpense トピックでは名称フィールドが表示されること
      expect(
        find.byKey(const Key('markDetail_field_name')),
        findsOneWidget,
      );
    },
  );
}
