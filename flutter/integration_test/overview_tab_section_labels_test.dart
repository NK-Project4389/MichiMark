// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: 概要タブ セクション名追加
///
/// Spec: docs/Spec/Features/FS-overview_tab_section_labels.md §5
/// テストシナリオ: TC-OSL-001 〜 TC-OSL-002
///
/// 前提条件:
///   - イベントが1件以上存在し、概要タブが表示可能な状態

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
    for (var i = 0; i < 20; i++) {
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

  /// イベント一覧の先頭アイテムをタップして EventDetail の概要タブを開く。
  /// 概要タブが表示された状態まで待つ。
  /// イベントが存在しない場合は null を返す。
  Future<bool> openOverviewTab(WidgetTester tester) async {
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    final gestureDetectors = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(GestureDetector),
    );
    if (gestureDetectors.evaluate().isEmpty) return false;

    await tester.tap(gestureDetectors.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('概要').evaluate().isNotEmpty) break;
    }
    // 概要タブが選択状態になるまで待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byIcon(Icons.edit).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  // ────────────────────────────────────────────────────────
  // TC-OSL-001: 「基本情報」ラベルが概要タブに表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-OSL-001: 「基本情報」ラベルが概要タブに表示される', (tester) async {
    await startApp(tester);

    final opened = await openOverviewTab(tester);
    if (!opened) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    expect(
      find.byKey(const Key('overview_sectionLabel_basicInfo')),
      findsOneWidget,
      reason: '「基本情報」セクションラベルウィジェットが存在すること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-OSL-001 (テキスト確認): 「基本情報」ラベルのテキストが正しい
  // ────────────────────────────────────────────────────────
  testWidgets('TC-OSL-001: 「基本情報」ラベルのテキストが「基本情報」である', (tester) async {
    await startApp(tester);

    final opened = await openOverviewTab(tester);
    if (!opened) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    final labelWidget = find.descendant(
      of: find.byKey(const Key('overview_sectionLabel_basicInfo')),
      matching: find.byType(Text),
    );
    expect(
      labelWidget,
      findsOneWidget,
      reason: '「基本情報」セクションラベル内にTextウィジェットが存在すること',
    );

    final text = tester.widget<Text>(labelWidget);
    expect(
      text.data,
      '基本情報',
      reason: '「基本情報」ラベルのテキストが「基本情報」であること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-OSL-002: 「集計」ラベルが概要タブに表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-OSL-002: 「集計」ラベルが概要タブに表示される', (tester) async {
    await startApp(tester);

    final opened = await openOverviewTab(tester);
    if (!opened) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 「集計」ラベルはスクロールが必要な場合があるため下方向にスクロールして探す
    for (var i = 0; i < 5; i++) {
      if (find
          .byKey(const Key('overview_sectionLabel_overview'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -300),
      );
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(
      find.byKey(const Key('overview_sectionLabel_overview')),
      findsOneWidget,
      reason: '「集計」セクションラベルウィジェットが存在すること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-OSL-002 (テキスト確認): 「集計」ラベルのテキストが正しい
  // ────────────────────────────────────────────────────────
  testWidgets('TC-OSL-002: 「集計」ラベルのテキストが「集計」である', (tester) async {
    await startApp(tester);

    final opened = await openOverviewTab(tester);
    if (!opened) {
      markTestSkipped('イベントデータが存在しないためスキップします');
      return;
    }

    // 「集計」ラベルはスクロールが必要な場合があるため下方向にスクロールして探す
    for (var i = 0; i < 5; i++) {
      if (find
          .byKey(const Key('overview_sectionLabel_overview'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -300),
      );
      await tester.pump(const Duration(milliseconds: 200));
    }

    final labelWidget = find.descendant(
      of: find.byKey(const Key('overview_sectionLabel_overview')),
      matching: find.byType(Text),
    );
    expect(
      labelWidget,
      findsOneWidget,
      reason: '「集計」セクションラベル内にTextウィジェットが存在すること',
    );

    final text = tester.widget<Text>(labelWidget);
    expect(
      text.data,
      '集計',
      reason: '「集計」ラベルのテキストが「集計」であること',
    );
  });
}
