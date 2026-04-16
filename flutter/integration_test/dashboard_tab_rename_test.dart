// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: UI-18 ダッシュボードタブ名変更
///
/// Spec: docs/Spec/Features/FS-dashboard_tab_rename.md
///
/// テストシナリオ: TC-RNM-001 〜 TC-RNM-004
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - アプリが起動できること

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
  // TC-RNM-001: ナビゲーションバーに「イベント一覧」タブラベルが表示される
  // ────────────────────────────────────────────────────────

  testWidgets('TC-RNM-001: ナビゲーションバーに「イベント一覧」タブラベルが表示されること',
      (tester) async {
    await startApp(tester);

    // BottomNavigationBar 内に「イベント一覧」テキストが表示されること
    expect(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('イベント一覧'),
      ),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-RNM-002: ナビゲーションバーに「イベント」（単独表記）が残っていない
  // ────────────────────────────────────────────────────────

  testWidgets('TC-RNM-002: ナビゲーションバーに「イベント」（単独表記）が残っていないこと',
      (tester) async {
    await startApp(tester);

    // BottomNavigationBar 内に「イベント」（単独・完全一致テキスト）が存在しないこと
    // find.text は完全一致なので「イベント一覧」にはヒットしない
    expect(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('イベント'),
      ),
      findsNothing,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-RNM-003: イベント一覧画面の AppBar タイトルが「イベント一覧」である
  // ────────────────────────────────────────────────────────

  testWidgets('TC-RNM-003: イベント一覧画面のAppBarタイトルが「イベント一覧」であること',
      (tester) async {
    await startApp(tester);

    // イベント一覧タブをタップ
    final eventListTab = find.byKey(const Key('event_list_tab'));
    expect(eventListTab, findsOneWidget);

    await tester.tap(eventListTab);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント一覧').evaluate().length >= 2) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // AppBar 内に「イベント一覧」テキストが表示されること
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('イベント一覧'),
      ),
      findsOneWidget,
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-RNM-004: タブの選択・切り替え動作に影響がない
  // ────────────────────────────────────────────────────────

  testWidgets('TC-RNM-004: タブの選択・切り替えが正常に動作すること', (tester) async {
    await startApp(tester);

    // イベント一覧タブをタップ
    final eventListTab = find.byKey(const Key('event_list_tab'));
    await tester.tap(eventListTab);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント一覧').evaluate().length >= 2) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // イベント一覧画面が表示されていること
    expect(find.byKey(const Key('event_list_tab')), findsOneWidget);

    // ダッシュボードタブに戻る
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
