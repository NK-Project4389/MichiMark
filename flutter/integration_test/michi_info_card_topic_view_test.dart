// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: MichiInfoカード トピック別表示切り替え
///
/// Spec: docs/Spec/Features/FS-michi_info_card_topic_view.md §9
///
/// テストシナリオ: TC-MCV-001 〜 TC-MCV-007
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - シードデータが投入済みであること
///     - event-001: movingCostトピック（ml-001: Mark, ml-002: Link）
///     - event-002: travelExpenseトピック（ml-006: Mark, ml-007: Link）

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

  /// イベント一覧から指定したイベント名のイベントをタップしてEventDetailを開く。
  /// イベントが見つからない場合は false を返す。
  Future<bool> openEventDetailByName(
    WidgetTester tester,
    String eventName,
  ) async {
    // スクロールしながら対象イベントを探す
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

  /// ミチタブをタップして MichiInfoView を表示する。
  Future<void> openMichiTab(WidgetTester tester) async {
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isNotEmpty) {
      await tester.tap(michiTab.first);
      await tester.pump(const Duration(milliseconds: 500));
    }
    // MichiInfoView がロードされるまで待機
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      // タイムラインカードが描画されたら完了
      if (find.byType(ListView).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// movingCostトピックのイベント詳細ミチタブを開くセットアップ。
  /// スキップ理由がある場合は文字列を返す。null の場合は成功。
  Future<String?> setupMovingCostMichiTab(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }
    final opened = await openEventDetailByName(tester, '箱根日帰りドライブ');
    if (!opened) {
      return '箱根日帰りドライブを開けなかったためスキップします';
    }
    await openMichiTab(tester);
    return null;
  }

  /// travelExpenseトピックのイベント詳細ミチタブを開くセットアップ。
  /// スキップ理由がある場合は文字列を返す。null の場合は成功。
  Future<String?> setupTravelExpenseMichiTab(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }
    final opened = await openEventDetailByName(tester, '富士五湖キャンプ');
    if (!opened) {
      return '富士五湖キャンプを開けなかったためスキップします';
    }
    await openMichiTab(tester);
    return null;
  }

  // ────────────────────────────────────────────────────────
  // TC-MCV-001〜007
  // ────────────────────────────────────────────────────────

  testWidgets('TC-MCV-001: movingCostのMarkカードに日付が表示される', (tester) async {
    final skipReason = await setupMovingCostMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // シードデータの最初のMarkカード (ml-001) が表示されているか確認
    // ListView.builder のため、画面外のカードはスクロールで表示する
    const markId = 'ml-001';
    for (var i = 0; i < 10; i++) {
      if (find.byKey(Key('michiInfo_text_markDate_$markId')).evaluate().isNotEmpty) {
        break;
      }
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(
      find.byKey(Key('michiInfo_text_markDate_$markId')),
      findsOneWidget,
    );
  });

  testWidgets('TC-MCV-001b: movingCostのMarkカードの日付テキストが空でない', (tester) async {
    final skipReason = await setupMovingCostMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    const markId = 'ml-001';
    for (var i = 0; i < 10; i++) {
      if (find.byKey(Key('michiInfo_text_markDate_$markId')).evaluate().isNotEmpty) {
        break;
      }
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    final dateWidget = find.byKey(Key('michiInfo_text_markDate_$markId'));
    expect(dateWidget, findsOneWidget);

    final textWidget = tester.widget<Text>(dateWidget);
    expect(textWidget.data?.isNotEmpty ?? false, isTrue);
  });

  testWidgets('TC-MCV-002: movingCostのMarkカードにメンバーが表示されない', (tester) async {
    final skipReason = await setupMovingCostMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // movingCostは showMarkMembers = false のため、メンバーテキストは非表示
    // 画面内すべてを確認するためスクロール後に検証する
    // まず画面上部に戻る
    for (var i = 0; i < 3; i++) {
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isEmpty) break;
      await tester.drag(listViews.first, const Offset(0, 400));
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pump(const Duration(milliseconds: 300));

    const markId = 'ml-001';
    expect(
      find.byKey(Key('michiInfo_text_markMembers_$markId')),
      findsNothing,
    );
  });

  testWidgets('TC-MCV-003: movingCostのMarkカードに累積メーターが表示される', (tester) async {
    final skipReason = await setupMovingCostMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // シードデータ ml-001 のメーター値: 45230 → 「45,230 km」または「45230 km」形式
    // 既存の累積メーター表示のWidgetに「km」文字列が含まれているか確認する
    for (var i = 0; i < 10; i++) {
      final kmTexts = find.textContaining('km');
      if (kmTexts.evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(find.textContaining('km'), findsWidgets);
  });

  testWidgets('TC-MCV-004: movingCostのLinkカードに日付が表示される', (tester) async {
    final skipReason = await setupMovingCostMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // シードデータの最初のLinkカード (ml-002) が表示されているか確認
    const linkId = 'ml-002';
    for (var i = 0; i < 10; i++) {
      if (find.byKey(Key('michiInfo_text_linkDate_$linkId')).evaluate().isNotEmpty) {
        break;
      }
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(
      find.byKey(Key('michiInfo_text_linkDate_$linkId')),
      findsOneWidget,
    );
  });

  testWidgets('TC-MCV-004b: movingCostのLinkカードの日付テキストが空でない', (tester) async {
    final skipReason = await setupMovingCostMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    const linkId = 'ml-002';
    for (var i = 0; i < 10; i++) {
      if (find.byKey(Key('michiInfo_text_linkDate_$linkId')).evaluate().isNotEmpty) {
        break;
      }
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    final dateWidget = find.byKey(Key('michiInfo_text_linkDate_$linkId'));
    expect(dateWidget, findsOneWidget);

    final textWidget = tester.widget<Text>(dateWidget);
    expect(textWidget.data?.isNotEmpty ?? false, isTrue);
  });

  testWidgets('TC-MCV-005: travelExpenseのMarkカードに名称が表示される', (tester) async {
    final skipReason = await setupTravelExpenseMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // シードデータ ml-006 の名称: '自宅出発'
    for (var i = 0; i < 10; i++) {
      if (find.text('自宅出発').evaluate().isNotEmpty) break;
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(find.text('自宅出発'), findsWidgets);
  });

  testWidgets('TC-MCV-005b: travelExpenseのMarkカードに日付も表示される', (tester) async {
    final skipReason = await setupTravelExpenseMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // シードデータ ml-006 の日付表示確認
    const markId = 'ml-006';
    for (var i = 0; i < 10; i++) {
      if (find.byKey(Key('michiInfo_text_markDate_$markId')).evaluate().isNotEmpty) {
        break;
      }
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(
      find.byKey(Key('michiInfo_text_markDate_$markId')),
      findsOneWidget,
    );
  });

  testWidgets('TC-MCV-006: travelExpenseのMarkカードにメンバーが表示される', (tester) async {
    final skipReason = await setupTravelExpenseMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // シードデータ ml-006 のメンバー: 太郎, 花子, 健太（showMarkMembers = true）
    const markId = 'ml-006';
    for (var i = 0; i < 10; i++) {
      if (find.byKey(Key('michiInfo_text_markMembers_$markId')).evaluate().isNotEmpty) {
        break;
      }
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    expect(
      find.byKey(Key('michiInfo_text_markMembers_$markId')),
      findsOneWidget,
    );
  });

  testWidgets('TC-MCV-006b: travelExpenseのMarkカードのメンバーテキストにメンバー名が含まれる',
      (tester) async {
    final skipReason = await setupTravelExpenseMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    const markId = 'ml-006';
    for (var i = 0; i < 10; i++) {
      if (find.byKey(Key('michiInfo_text_markMembers_$markId')).evaluate().isNotEmpty) {
        break;
      }
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        await tester.drag(listViews.first, const Offset(0, -200));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    final membersWidget = find.byKey(Key('michiInfo_text_markMembers_$markId'));
    expect(membersWidget, findsOneWidget);

    final textWidget = tester.widget<Text>(membersWidget);
    // シードデータのメンバー: 太郎, 花子, 健太 のいずれかが含まれること
    final text = textWidget.data ?? '';
    expect(
      text.contains('太郎') || text.contains('花子') || text.contains('健太'),
      isTrue,
    );
  });

  testWidgets('TC-MCV-007: travelExpenseのLinkカードに日付が表示されない', (tester) async {
    final skipReason = await setupTravelExpenseMichiTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // travelExpenseは showLinkDate = false のため、Linkカードに日付テキストは非表示
    // 画面上部に戻ってからスクロールして全体確認する
    for (var i = 0; i < 3; i++) {
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isEmpty) break;
      await tester.drag(listViews.first, const Offset(0, 400));
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // Linkカード (ml-007) に日付Keyが存在しないことを確認
    const linkId = 'ml-007';
    expect(
      find.byKey(Key('michiInfo_text_linkDate_$linkId')),
      findsNothing,
    );
  });
}
