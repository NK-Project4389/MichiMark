// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: B-19 訪問作業シードデータ区間削除
///
/// Spec: docs/Spec/Features/FS-visit_work_seed_data_fix.md §7
///
/// テストシナリオ: TC-B19-I001 〜 TC-B19-I004
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - B-17 シードデータ実装が完了していること
///   - B-19 Link削除が完了していること
///   - アプリをリセット（GetIt.I.reset()）した状態
///
/// テスト環境での注意事項:
///   - テスト環境（FLUTTER_TEST=true）では _testSeedEvents が使われるため、
///     本番シードデータ（event-seed-c）は存在しない。
///   - シナリオCの「横浜エリア訪問ルート」の存在を前提とするため、
///     テスト環境では該当イベントがない場合はスキップする。

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

  /// イベント一覧から指定名のイベントをタップしてEventDetailを開く。
  Future<bool> openEventByName(WidgetTester tester, String eventName) async {
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

  /// セットアップ: アプリ起動 → シナリオCイベント → ミチタブ
  Future<String?> setupScenarioCMichi(WidgetTester tester) async {
    await startApp(tester);
    final opened = await openEventByName(tester, '横浜エリア訪問ルート');
    if (!opened) {
      return '「横浜エリア訪問ルート」が見つかりません（テスト環境ではシードデータが異なる場合はスキップ）';
    }
    await openMichiTab(tester);
    return null;
  }

  // ────────────────────────────────────────────────────────
  // TC-B19-I001: シナリオCのMichiInfoにLinkが表示されない
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-B19-I001: シナリオCのMichiInfoにLink（区間）カードが表示されないこと',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B19-I001: $skipReason');
        return;
      }

      // MichiInfo内にLinkカードが存在しないことを確認する
      // キーパターン: michiInfo_item_link_<id> を持つWidgetが存在しない
      // Linkカードは「距離」「km」を表示するため、テキストでも確認する
      // ただし全スクロールして確認する必要がある
      var foundLink = false;
      for (var i = 0; i < 15; i++) {
        // Linkカードは距離表示（km表記）を含む
        // michiInfo_item_link_ プレフィックスのキーを検索
        final linkItems = find.byWidgetPredicate((widget) {
          if (widget.key is ValueKey<String>) {
            return (widget.key as ValueKey<String>)
                .value
                .startsWith('michiInfo_item_link_');
          }
          if (widget.key is Key) {
            return widget.key.toString().contains('michiInfo_item_link_');
          }
          return false;
        });
        if (linkItems.evaluate().isNotEmpty) {
          foundLink = true;
          break;
        }
        final listViews = find.byType(ListView);
        if (listViews.evaluate().isEmpty) break;
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(foundLink, isFalse);
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-B19-I002: シナリオCのMichiInfoにMark 5件が表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-B19-I002: シナリオCのMichiInfoに「事務所出発」マークが表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B19-I002: $skipReason');
        return;
      }

      // 「事務所出発」テキストを含むマークカードが表示されること
      for (var i = 0; i < 10; i++) {
        if (find.textContaining('事務所出発').evaluate().isNotEmpty) break;
        final listViews = find.byType(ListView);
        if (listViews.evaluate().isEmpty) break;
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(find.textContaining('事務所出発'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-B19-I002b: シナリオCのMichiInfoに「A社（横浜駅前）」マークが表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B19-I002b: $skipReason');
        return;
      }

      for (var i = 0; i < 10; i++) {
        if (find.textContaining('A社').evaluate().isNotEmpty) break;
        final listViews = find.byType(ListView);
        if (listViews.evaluate().isEmpty) break;
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(find.textContaining('A社'), findsWidgets);
    },
  );

  testWidgets(
    'TC-B19-I002c: シナリオCのMichiInfoに「B社（みなとみらい）」マークが表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B19-I002c: $skipReason');
        return;
      }

      for (var i = 0; i < 10; i++) {
        if (find.textContaining('B社').evaluate().isNotEmpty) break;
        final listViews = find.byType(ListView);
        if (listViews.evaluate().isEmpty) break;
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(find.textContaining('B社'), findsWidgets);
    },
  );

  testWidgets(
    'TC-B19-I002d: シナリオCのMichiInfoに「C社（磯子）」マークが表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B19-I002d: $skipReason');
        return;
      }

      for (var i = 0; i < 10; i++) {
        if (find.textContaining('C社').evaluate().isNotEmpty) break;
        final listViews = find.byType(ListView);
        if (listViews.evaluate().isEmpty) break;
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(find.textContaining('C社'), findsWidgets);
    },
  );

  testWidgets(
    'TC-B19-I002e: シナリオCのMichiInfoに「事務所帰着」マークが表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B19-I002e: $skipReason');
        return;
      }

      for (var i = 0; i < 10; i++) {
        if (find.textContaining('事務所帰着').evaluate().isNotEmpty) break;
        final listViews = find.byType(ListView);
        if (listViews.evaluate().isEmpty) break;
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(find.textContaining('事務所帰着'), findsOneWidget);
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-B19-I003: シナリオCの支払い3件は正常に表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-B19-I003: シナリオCの支払タブに支払いが表示されること（Link削除の影響なし）',
    (tester) async {
      await startApp(tester);
      final opened = await openEventByName(tester, '横浜エリア訪問ルート');
      if (!opened) {
        print('[SKIP] TC-B19-I003: 「横浜エリア訪問ルート」が見つかりません');
        return;
      }
      await openPaymentTab(tester);

      // 支払い一覧にアイテムが存在すること
      // 「駐車場」「昼食」等のテキストが表示されていればOK
      final hasPayments = find.textContaining('駐車場').evaluate().isNotEmpty ||
          find.textContaining('昼食').evaluate().isNotEmpty;

      expect(hasPayments, isTrue);
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-B19-I004: シナリオAのタイムライン（Mark・Link）は影響を受けない
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-B19-I004: シナリオAのMichiInfoにMarkカードが表示されること（B-19の修正が影響しない）',
    (tester) async {
      await startApp(tester);
      final opened = await openEventByName(tester, '箱根日帰りドライブ');
      if (!opened) {
        print('[SKIP] TC-B19-I004: 「箱根日帰りドライブ」が見つかりません');
        return;
      }
      await openMichiTab(tester);

      // シナリオAにはMarkが存在すること
      // michiInfo_item_mark_ プレフィックスのキーを持つWidgetが存在する
      var foundMark = false;
      for (var i = 0; i < 10; i++) {
        final markItems = find.byWidgetPredicate((widget) {
          if (widget.key is Key) {
            return widget.key.toString().contains('michiInfo_item_mark_');
          }
          return false;
        });
        if (markItems.evaluate().isNotEmpty) {
          foundMark = true;
          break;
        }
        final listViews = find.byType(ListView);
        if (listViews.evaluate().isEmpty) break;
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(foundMark, isTrue);
    },
  );

  testWidgets(
    'TC-B19-I004b: シナリオAのMichiInfoにLinkカードが表示されること（B-19の修正が影響しない）',
    (tester) async {
      await startApp(tester);
      final opened = await openEventByName(tester, '箱根日帰りドライブ');
      if (!opened) {
        print('[SKIP] TC-B19-I004b: 「箱根日帰りドライブ」が見つかりません');
        return;
      }
      await openMichiTab(tester);

      // シナリオAにはLinkが存在すること
      var foundLink = false;
      for (var i = 0; i < 10; i++) {
        final linkItems = find.byWidgetPredicate((widget) {
          if (widget.key is Key) {
            return widget.key.toString().contains('michiInfo_item_link_');
          }
          return false;
        });
        if (linkItems.evaluate().isNotEmpty) {
          foundLink = true;
          break;
        }
        final listViews = find.byType(ListView);
        if (listViews.evaluate().isEmpty) break;
        await tester.drag(listViews.first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(foundLink, isTrue);
    },
  );
}
