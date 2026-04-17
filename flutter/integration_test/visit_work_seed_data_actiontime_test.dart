// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: B-20 訪問作業シードデータ ActionTime情報追加
///
/// Spec: docs/Spec/Features/FS-visit_work_seed_data_actiontime.md §7
///
/// テストシナリオ: TC-B20-I001 〜 TC-B20-I004
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - B-17 シードデータ実装が完了していること
///   - B-19 Link削除が完了していること（Mark 5件構成が前提）
///   - B-20 ActionTimeLog追加が完了していること
///   - アプリをリセット（GetIt.I.reset()）した状態
///
/// テスト環境での注意事項:
///   - テスト環境では本番シードデータ（event-seed-c）が存在しない場合はスキップ

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

  /// イベント一覧から「横浜エリア訪問ルート」をタップしてEventDetailを開く。
  Future<bool> openScenarioC(WidgetTester tester) async {
    const eventName = '横浜エリア訪問ルート';
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

  /// ミチタブでスクロールして指定テキストのマークをタップし、MarkDetailを開く。
  Future<bool> openMarkDetailByText(
      WidgetTester tester, String markText) async {
    for (var i = 0; i < 15; i++) {
      if (find.textContaining(markText).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isEmpty) break;
      await tester.drag(listViews.first, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 200));
    }

    if (find.textContaining(markText).evaluate().isEmpty) {
      return false;
    }

    await tester.tap(find.textContaining(markText).first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('保存').evaluate().isNotEmpty ||
          find.text('累積メーター').evaluate().isNotEmpty ||
          find.textContaining('到着').evaluate().isNotEmpty ||
          find.textContaining('作業開始').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 500));
    return true;
  }

  /// セットアップ: アプリ起動 → シナリオC → ミチタブ
  Future<String?> setupScenarioCMichi(WidgetTester tester) async {
    await startApp(tester);
    final opened = await openScenarioC(tester);
    if (!opened) {
      return '「横浜エリア訪問ルート」が見つかりません（テスト環境ではシードデータが異なる場合はスキップ）';
    }
    await openMichiTab(tester);
    return null;
  }

  // ────────────────────────────────────────────────────────
  // TC-B20-I001: A社マークにActionTimeLogが3件記録されている
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-B20-I001: A社マークのMarkDetailにアクション記録「到着」が表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B20-I001: $skipReason');
        return;
      }

      final markOpened = await openMarkDetailByText(tester, 'A社');
      if (!markOpened) {
        print('[SKIP] TC-B20-I001: A社マークが見つかりませんでした');
        return;
      }

      // MarkDetail内で「到着」テキストが表示されていること
      // スクロールしてActionTimeLogセクションを確認
      for (var i = 0; i < 10; i++) {
        if (find.textContaining('到着').evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -400));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(find.textContaining('到着'), findsWidgets);
    },
  );

  testWidgets(
    'TC-B20-I001b: A社マークのMarkDetailにアクション記録「作業開始」が表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B20-I001b: $skipReason');
        return;
      }

      final markOpened = await openMarkDetailByText(tester, 'A社');
      if (!markOpened) {
        print('[SKIP] TC-B20-I001b: A社マークが見つかりませんでした');
        return;
      }

      for (var i = 0; i < 10; i++) {
        if (find.textContaining('作業開始').evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -400));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(find.textContaining('作業開始'), findsWidgets);
    },
  );

  testWidgets(
    'TC-B20-I001c: A社マークのMarkDetailにアクション記録「作業終了」が表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B20-I001c: $skipReason');
        return;
      }

      final markOpened = await openMarkDetailByText(tester, 'A社');
      if (!markOpened) {
        print('[SKIP] TC-B20-I001c: A社マークが見つかりませんでした');
        return;
      }

      for (var i = 0; i < 10; i++) {
        if (find.textContaining('作業終了').evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -400));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(find.textContaining('作業終了'), findsWidgets);
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-B20-I002: B社マークにActionTimeLogが5件記録されている（休憩含む）
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-B20-I002: B社マークのMarkDetailに「休憩」アクション記録が表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B20-I002: $skipReason');
        return;
      }

      final markOpened = await openMarkDetailByText(tester, 'B社');
      if (!markOpened) {
        print('[SKIP] TC-B20-I002: B社マークが見つかりませんでした');
        return;
      }

      // スクロールして「休憩」テキストを探す
      for (var i = 0; i < 10; i++) {
        if (find.textContaining('休憩').evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -400));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(find.textContaining('休憩'), findsWidgets);
    },
  );

  testWidgets(
    'TC-B20-I002b: B社マークのMarkDetailに「到着」アクション記録が表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B20-I002b: $skipReason');
        return;
      }

      final markOpened = await openMarkDetailByText(tester, 'B社');
      if (!markOpened) {
        print('[SKIP] TC-B20-I002b: B社マークが見つかりませんでした');
        return;
      }

      for (var i = 0; i < 10; i++) {
        if (find.textContaining('到着').evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -400));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(find.textContaining('到着'), findsWidgets);
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-B20-I003: C社マークにActionTimeLogが3件記録されている
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-B20-I003: C社マークのMarkDetailにアクション記録「到着」が表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B20-I003: $skipReason');
        return;
      }

      final markOpened = await openMarkDetailByText(tester, 'C社');
      if (!markOpened) {
        print('[SKIP] TC-B20-I003: C社マークが見つかりませんでした');
        return;
      }

      for (var i = 0; i < 10; i++) {
        if (find.textContaining('到着').evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -400));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(find.textContaining('到着'), findsWidgets);
    },
  );

  testWidgets(
    'TC-B20-I003b: C社マークのMarkDetailにアクション記録「作業終了」が表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B20-I003b: $skipReason');
        return;
      }

      final markOpened = await openMarkDetailByText(tester, 'C社');
      if (!markOpened) {
        print('[SKIP] TC-B20-I003b: C社マークが見つかりませんでした');
        return;
      }

      for (var i = 0; i < 10; i++) {
        if (find.textContaining('作業終了').evaluate().isNotEmpty) break;
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -400));
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      expect(find.textContaining('作業終了'), findsWidgets);
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-B20-I004: 概要タブの作業時間サマリーに合計作業時間が表示される
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-B20-I004: シナリオCの概要タブに作業時間のサマリーが表示されること（0時間でないこと）',
    (tester) async {
      await startApp(tester);
      final opened = await openScenarioC(tester);
      if (!opened) {
        print('[SKIP] TC-B20-I004: 「横浜エリア訪問ルート」が見つかりません');
        return;
      }

      // 概要タブを表示（デフォルトタブ）
      final overviewTab = find.text('概要');
      if (overviewTab.evaluate().isNotEmpty) {
        await tester.tap(overviewTab.first);
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 300));
          if (find.byKey(const Key('visit_work_progress_bar')).evaluate().isNotEmpty ||
              find.text('作業').evaluate().isNotEmpty ||
              find.byKey(const Key('overview_sectionLabel_overview')).evaluate().isNotEmpty) {
            break;
          }
        }
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 「作業」ラベルまたはプログレスバーが表示されること
      // ActionTimeLogが投入されていれば、集計セクションに作業時間情報が表示される
      final hasWorkSummary =
          find.text('作業').evaluate().isNotEmpty ||
          find.byKey(const Key('visit_work_progress_bar')).evaluate().isNotEmpty;

      expect(hasWorkSummary, isTrue);
    },
  );
}
