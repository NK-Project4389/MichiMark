// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: UI-17 ダッシュボードタブ左側配置・初期タブ化
///
/// Spec: docs/Spec/Features/FS-dashboard_tab_position.md
///
/// テストシナリオ: TC-TAB-001 〜 TC-TAB-004
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - アプリが初期状態で起動できること

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

  /// アプリを起動してダッシュボード画面が表示されるまで待つ。
  /// initialLocation が /dashboard なので、起動直後にダッシュボードが表示される想定。
  Future<void> startApp(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/dashboard');
    app.main();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('dashboard_tab')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ────────────────────────────────────────────────────────
  // TC-TAB-001: アプリ起動時にダッシュボードが最初に表示される
  // ────────────────────────────────────────────────────────

  testWidgets('TC-TAB-001: アプリ起動時にダッシュボードが最初に表示されること', (tester) async {
    await startApp(tester);

    expect(find.byKey(const Key('dashboard_tab')), findsOneWidget);
  });

  // ────────────────────────────────────────────────────────
  // TC-TAB-002: ダッシュボードタブがナビゲーションバーの左側（先頭）に表示される
  // ────────────────────────────────────────────────────────

  testWidgets('TC-TAB-002: ダッシュボードタブがイベント一覧タブより左側に配置されていること',
      (tester) async {
    await startApp(tester);

    final dashboardTab = find.byKey(const Key('dashboard_tab'));
    final eventListTab = find.byKey(const Key('event_list_tab'));

    expect(dashboardTab, findsOneWidget);
    expect(eventListTab, findsOneWidget);

    // ダッシュボードタブのX座標がイベント一覧タブのX座標より小さい（左側にある）
    final dashboardRect = tester.getRect(dashboardTab);
    final eventListRect = tester.getRect(eventListTab);
    expect(dashboardRect.left < eventListRect.left, isTrue);
  });

  // ────────────────────────────────────────────────────────
  // TC-TAB-003: イベント一覧タブをタップすると一覧画面に切り替わる
  // ────────────────────────────────────────────────────────

  testWidgets('TC-TAB-003: イベント一覧タブをタップするとイベント一覧画面に切り替わること',
      (tester) async {
    await startApp(tester);

    final eventListTab = find.byKey(const Key('event_list_tab'));
    expect(eventListTab, findsOneWidget);

    await tester.tap(eventListTab);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント一覧').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // イベント一覧画面が表示されていること（テキストまたはListViewの存在で判定）
    expect(find.text('イベント一覧'), findsWidgets);
  });

  // ────────────────────────────────────────────────────────
  // TC-TAB-004: ダッシュボードタブをタップするとダッシュボード画面に戻る
  // ────────────────────────────────────────────────────────

  testWidgets('TC-TAB-004: イベント一覧からダッシュボードタブをタップするとダッシュボードに戻ること',
      (tester) async {
    await startApp(tester);

    // まずイベント一覧に切り替え
    final eventListTab = find.byKey(const Key('event_list_tab'));
    await tester.tap(eventListTab);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント一覧').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // ダッシュボードタブをタップして戻る
    final dashboardTab = find.byKey(const Key('dashboard_tab'));
    await tester.tap(dashboardTab);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('ダッシュボード').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // ダッシュボード画面が表示されていること
    expect(find.text('ダッシュボード'), findsWidgets);
  });
}
