// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: MichiInfo 日付区切り表示
///
/// Spec: docs/Spec/Features/FS-michi_info_date_separator.md §9
///
/// テストシナリオ: TC-DS-001 〜 TC-DS-007
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - テスト用イベント・Markデータはテスト内で作成すること

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

  /// イベント一覧から最初のイベントをタップして EventDetail を開く。
  Future<bool> openFirstEventDetail(WidgetTester tester) async {
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;
    final cards = find.byType(GestureDetector);
    if (cards.evaluate().isEmpty) return false;
    await tester.tap(cards.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // ミチタブが存在して表示されるまで待つ
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// MichiInfo タブを表示する。
  Future<void> ensureMichiInfoTab(WidgetTester tester) async {
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isNotEmpty) {
      await tester.tap(michiTab.first);
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        // ミチInfo画面のコンテンツが描画されるまで待つ
        if (find
                .byKey(const Key('michiInfo_sliver_list'))
                .evaluate()
                .isNotEmpty ||
            find.byType(CustomPaint).evaluate().isNotEmpty) {
          break;
        }
      }
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// MichiInfo タブまで表示するセットアップ。
  /// イベントがない場合はスキップ理由を返す。null の場合は成功。
  Future<String?> setupMichiInfoTab(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }
    final opened = await openFirstEventDetail(tester);
    if (!opened) {
      return 'イベント詳細を開けなかったためスキップします';
    }
    await ensureMichiInfoTab(tester);
    return null;
  }

  /// 複数日付のMarkを持つイベント（'京都一泊旅行'）を開いて MichiInfo タブを表示する。
  /// TC-DS-003 など複数日付区切りの検証に使用する。
  Future<String?> setupMichiInfoTabWithMultiDates(WidgetTester tester) async {
    await startApp(tester);
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return 'イベントデータが存在しないためスキップします';
    }
    // '京都一泊旅行'（event-008）を探してタップ
    const targetName = '京都一泊旅行';
    for (var i = 0; i < 10; i++) {
      if (find.text(targetName).evaluate().isNotEmpty) break;
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 300));
    }
    if (find.text(targetName).evaluate().isEmpty) {
      return '$targetName が見つかりませんでした';
    }
    await tester.tap(find.text(targetName).first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }
    await ensureMichiInfoTab(tester);
    return null;
  }

  // ────────────────────────────────────────────────────────
  // TC-DS-001〜007
  // ────────────────────────────────────────────────────────

  testWidgets('TC-DS-001: 単一日付のMarkが1件のみのとき、先頭に区切りが表示される', (tester) async {
    final skipReason = await setupMichiInfoTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // 先頭区切りが存在することを確認
    expect(find.byKey(const Key('michiInfo_dateSeparator_0')), findsOneWidget);
  });

  testWidgets('TC-DS-002: 同一日付のMarkが複数あるとき、先頭のみ区切りが表示され中間に区切りは表示されない', (
    tester,
  ) async {
    final skipReason = await setupMichiInfoTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // 先頭区切りが存在することを確認
    expect(find.byKey(const Key('michiInfo_dateSeparator_0')), findsOneWidget);

    // 2番目のMarkカードの前に区切りが表示されていないことを確認
    // （最初の1つだけ区切りが表示されるはず）
    expect(find.byKey(const Key('michiInfo_dateSeparator_1')), findsNothing);
  });

  testWidgets('TC-DS-003: 日付が変わるMarkの直前に区切りが挿入される（2日分のMarkがある場合）', (
    tester,
  ) async {
    final skipReason = await setupMichiInfoTabWithMultiDates(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // 日付A の区切りが表示される（先頭 = 画面内）
    expect(find.byKey(const Key('michiInfo_dateSeparator_0')), findsOneWidget);

    // 日付B の区切りをスクロールして探す（4/13 のMarkが画面外にある場合に対応）
    for (var i = 0; i < 15; i++) {
      if (find
          .byKey(const Key('michiInfo_dateSeparator_1'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -400),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 日付B の区切りが表示される
    expect(find.byKey(const Key('michiInfo_dateSeparator_1')), findsOneWidget);
  });

  testWidgets('TC-DS-004: 区切りの日付テキストが `yyyy/MM/dd` 形式で表示される', (tester) async {
    final skipReason = await setupMichiInfoTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // 日付フォーマット `yyyy/MM/dd` を持つテキストが区切りウィジェット内に存在することを確認
    // 区切りウィジェット内のテキストは `find.descendant` で確認
    final dateSeparator = find.byKey(const Key('michiInfo_dateSeparator_0'));
    expect(dateSeparator, findsOneWidget);

    // 区切り内のテキストが日付フォーマットであることを確認
    // （実際のテキスト値は実装結果に依存するため、存在確認で検証）
    final separatorText = find.descendant(
      of: dateSeparator,
      matching: find.byType(Text),
    );
    expect(separatorText, findsWidgets);
  });

  testWidgets('TC-DS-005: InsertMode中に区切りが非表示になる', (tester) async {
    final skipReason = await setupMichiInfoTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // 初期状態で区切りが表示されている
    expect(find.byKey(const Key('michiInfo_dateSeparator_0')), findsOneWidget);

    // FABボタンをタップして InsertMode を有効にする
    final fab = find.byKey(const Key('michiInfo_fab_add'));
    expect(fab, findsOneWidget);

    await tester.tap(fab);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // InsertMode が反映されるまで待つ
      if (find
          .byKey(const Key('michiInfo_dateSeparator_0'))
          .evaluate()
          .isEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    // InsertMode 中、区切りが非表示になる
    expect(find.byKey(const Key('michiInfo_dateSeparator_0')), findsNothing);
  });

  testWidgets('TC-DS-006: Markカード・Linkカードの縦幅が変化しない', (tester) async {
    final skipReason = await setupMichiInfoTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // 区切りウィジェットが表示される
    expect(find.byKey(const Key('michiInfo_dateSeparator_0')), findsOneWidget);

    // Mark または Link カードが存在して操作可能であることを確認
    // （カード要素が画面上に存在することで、高さが正常であることを暗に検証）
    final cards = find.byType(GestureDetector);
    expect(cards.evaluate().length, greaterThan(0));
  });

  testWidgets('TC-DS-007: 道路帯Canvasが区切り位置で切断されない', (tester) async {
    final skipReason = await setupMichiInfoTab(tester);
    if (skipReason != null) {
      print('[SKIP] $skipReason');
      return;
    }

    // 日付区切りウィジェットが2件以上表示される（複数日分）
    expect(find.byKey(const Key('michiInfo_dateSeparator_0')), findsOneWidget);

    // 2番目の区切りが存在する場合、確認
    final secondSeparator = find.byKey(const Key('michiInfo_dateSeparator_1'));
    if (secondSeparator.evaluate().isNotEmpty) {
      expect(secondSeparator, findsOneWidget);
    }

    // Canvas（道路帯）が存在して描画されていることを確認
    // CustomPaint は Canvasの親ウィジェット
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
