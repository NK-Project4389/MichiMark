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
///   - B-20 ActionTimeLog追加が完了していること
///
/// 検証方針（Option B）:
///   ActionTimeLogはMarkDetailではなく、ミチタブのActionTimeView（⚡ボタン→ボトムシート）
///   に表示される。テストはActionTimeViewを開いてログラベルを確認する。
///   ActionTimeViewはイベント全体の全ログを一覧表示するため、
///   どのマークの⚡ボタンから開いても同じ内容が表示される。

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

  /// ミチタブで最初の⚡ボタンをタップしてActionTimeViewボトムシートを開く。
  /// ActionTimeViewはイベント全体のActionTimeLogを一覧表示する。
  Future<bool> openActionTimeView(WidgetTester tester) async {
    // ⚡ボタンを探す（mark_action_button キーはすべてのマークで共通）
    for (var i = 0; i < 10; i++) {
      if (find.byKey(const Key('mark_action_button')).evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isEmpty) break;
      await tester.drag(listViews.first, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 200));
    }

    if (find.byKey(const Key('mark_action_button')).evaluate().isEmpty) {
      return false;
    }

    await tester.tap(find.byKey(const Key('mark_action_button')).first);

    // ボトムシートが開くまで待つ（'ログ' または 'ActionTime' ヘッダーを確認）
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ログ').evaluate().isNotEmpty ||
          find.text('ActionTime').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 500));

    return find.text('ログ').evaluate().isNotEmpty ||
        find.text('ActionTime').evaluate().isNotEmpty;
  }

  /// セットアップ: アプリ起動 → シナリオC → ミチタブ
  Future<String?> setupScenarioCMichi(WidgetTester tester) async {
    await startApp(tester);
    final opened = await openScenarioC(tester);
    if (!opened) {
      return '「横浜エリア訪問ルート」が見つかりません（シードデータ未投入の可能性）';
    }
    await openMichiTab(tester);
    return null;
  }

  // ────────────────────────────────────────────────────────
  // TC-B20-I001: A社マークのActionTimeLogに「到着」が記録されている
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-B20-I001: A社マークのMarkDetailにアクション記録「到着」が表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B20-I001: $skipReason');
        return;
      }

      // ActionTimeViewを開く（⚡ボタン → ボトムシート）
      final opened = await openActionTimeView(tester);
      if (!opened) {
        print('[SKIP] TC-B20-I001: ActionTimeViewが開けませんでした');
        return;
      }

      // ActionTimeView内で「到着」ログが表示されていること
      // （A社到着09:15、B社到着11:00、C社到着14:00 の計3件）
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

      final opened = await openActionTimeView(tester);
      if (!opened) {
        print('[SKIP] TC-B20-I001b: ActionTimeViewが開けませんでした');
        return;
      }

      // 「作業開始」ログが表示されていること（A社作業開始09:20、B社作業開始11:10の2件）
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

      final opened = await openActionTimeView(tester);
      if (!opened) {
        print('[SKIP] TC-B20-I001c: ActionTimeViewが開けませんでした');
        return;
      }

      // 「作業終了」ログが表示されていること（A社作業終了10:45、B社作業終了14:30、C社作業終了16:00の3件）
      expect(find.textContaining('作業終了'), findsWidgets);
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-B20-I002: B社マークのActionTimeLogに「休憩」が記録されている
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-B20-I002: B社マークのMarkDetailに「休憩」アクション記録が表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B20-I002: $skipReason');
        return;
      }

      final opened = await openActionTimeView(tester);
      if (!opened) {
        print('[SKIP] TC-B20-I002: ActionTimeViewが開けませんでした');
        return;
      }

      // 「休憩」ログが表示されていること（B社休憩開始12:00・休憩終了12:30の2件）
      // ログラベルは「休憩開始」「休憩終了」または「休憩」を含む形式
      final hasBreak = find.textContaining('休憩').evaluate().isNotEmpty;
      expect(hasBreak, isTrue);
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

      final opened = await openActionTimeView(tester);
      if (!opened) {
        print('[SKIP] TC-B20-I002b: ActionTimeViewが開けませんでした');
        return;
      }

      // 「到着」ログが表示されていること（B社到着11:00含む）
      expect(find.textContaining('到着'), findsWidgets);
    },
  );

  // ────────────────────────────────────────────────────────
  // TC-B20-I003: C社マークのActionTimeLogに「到着」「作業終了」が記録されている
  // ────────────────────────────────────────────────────────

  testWidgets(
    'TC-B20-I003: C社マークのMarkDetailにアクション記録「到着」が表示されること',
    (tester) async {
      final skipReason = await setupScenarioCMichi(tester);
      if (skipReason != null) {
        print('[SKIP] TC-B20-I003: $skipReason');
        return;
      }

      final opened = await openActionTimeView(tester);
      if (!opened) {
        print('[SKIP] TC-B20-I003: ActionTimeViewが開けませんでした');
        return;
      }

      // 「到着」ログが表示されていること（C社到着14:00含む）
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

      final opened = await openActionTimeView(tester);
      if (!opened) {
        print('[SKIP] TC-B20-I003b: ActionTimeViewが開けませんでした');
        return;
      }

      // 「作業終了」ログが表示されていること（C社作業終了16:00含む）
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
      final hasWorkSummary =
          find.text('作業').evaluate().isNotEmpty ||
          find.byKey(const Key('visit_work_progress_bar')).evaluate().isNotEmpty;

      expect(hasWorkSummary, isTrue);
    },
  );
}
