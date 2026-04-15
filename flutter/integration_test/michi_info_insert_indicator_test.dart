// ignore_for_file: avoid_print

/// Integration Test: MichiInfo 挿入インジケーター改善
///
/// Spec: docs/Spec/Features/FS-michi_info_insert_button_size.md §8
/// テストシナリオ: TC-MIB-001 〜 TC-MIB-005

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ────────────────────────────────────────────────────────
  // ヘルパー
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
      if (find.text('箱根日帰りドライブ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// アプリを起動して MichiInfo タブまで遷移する。
  /// 前提: 「箱根日帰りドライブ」には 2件以上のマーク/リンクが存在すること。
  Future<void> goToMichiInfoTab(WidgetTester tester) async {
    await startApp(tester);

    final eventCards = find.ancestor(
      of: find.text('箱根日帰りドライブ'),
      matching: find.byType(GestureDetector),
    );
    expect(eventCards, findsWidgets,
        reason: '「箱根日帰りドライブ」のイベントカードが見つかること');

    await tester.tap(eventCards.first);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }

    final michiTab = find.text('ミチ');
    expect(michiTab, findsOneWidget, reason: '「ミチ」タブが表示されること');
    await tester.tap(michiTab);
    await tester.pump(const Duration(milliseconds: 500));

    // MichiInfo ページのロードを待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// MarkDetail 画面がロードされるまで待つ。
  Future<bool> waitForMarkDetailScreen(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('保存').evaluate().isNotEmpty ||
          find.text('名称（任意）').evaluate().isNotEmpty ||
          find.text('地点詳細').evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // ────────────────────────────────────────────────────────
  // TC-MIB-001: InsertMode OFF 時にインジケーターが表示されないこと
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MIB-001: InsertMode OFF 時にインジケーターが表示されないこと',
      (tester) async {
    await goToMichiInfoTab(tester);

    // InsertMode が OFF の状態（FABタップ前）を確認
    // 先頭インジケーターが存在しないこと
    expect(
      find.byKey(const Key('michiInfo_button_insertIndicator_head')),
      findsNothing,
      reason: 'InsertMode OFF 時は michiInfo_button_insertIndicator_head が存在しないこと',
    );

    // add_circle アイコン（インジケーター）が画面上に存在しないこと
    expect(
      find.byIcon(Icons.add_circle),
      findsNothing,
      reason: 'InsertMode OFF 時はインジケーターアイコンが表示されないこと',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MIB-002: InsertMode ON 時に先頭カードの前にインジケーターが表示されること
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MIB-002: InsertMode ON 時に先頭カードの前にインジケーターが表示されること',
      (tester) async {
    await goToMichiInfoTab(tester);

    // FABをタップして InsertMode を ON にする
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget, reason: 'FABが表示されること');
    await tester.tap(fab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_button_insertIndicator_head')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 先頭インジケーター（michiInfo_button_insertIndicator_head）が表示されること
    expect(
      find.byKey(const Key('michiInfo_button_insertIndicator_head')),
      findsOneWidget,
      reason: 'InsertMode ON 時は michiInfo_button_insertIndicator_head が先頭に表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MIB-003: InsertMode ON 時にカード間にインジケーターが表示されること
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MIB-003: InsertMode ON 時にカード間にインジケーターが表示されること',
      (tester) async {
    await goToMichiInfoTab(tester);

    // FABをタップして InsertMode を ON にする
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget, reason: 'FABが表示されること');
    await tester.tap(fab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byIcon(Icons.add_circle).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // add_circle アイコンが複数存在すること（先頭 + カード間）
    final indicators = find.byIcon(Icons.add_circle);
    expect(
      indicators,
      findsWidgets,
      reason: 'InsertMode ON 時は add_circle インジケーターが複数表示されること',
    );

    // 先頭インジケーターに加え、カード間インジケーターも存在すること
    // （件数が先頭1つ + カード数分）
    final indicatorCount = indicators.evaluate().length;
    expect(
      indicatorCount,
      greaterThanOrEqualTo(2),
      reason: 'InsertMode ON 時は先頭インジケーターとカード間インジケーターが合わせて2件以上表示されること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MIB-004: 先頭インジケーターをタップすると先頭挿入フローが起動すること
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MIB-004: 先頭インジケーターをタップすると先頭挿入フローが起動すること',
      (tester) async {
    await goToMichiInfoTab(tester);

    // FABをタップして InsertMode を ON にする
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget, reason: 'FABが表示されること');
    await tester.tap(fab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('michiInfo_button_insertIndicator_head')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // 先頭インジケーターが表示されていること
    final topIndicator = find.byKey(const Key('michiInfo_button_insertIndicator_head'));
    expect(topIndicator, findsOneWidget, reason: '先頭インジケーターが表示されること');

    // 先頭インジケーターをタップ
    await tester.ensureVisible(topIndicator);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(topIndicator);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('地点を追加').evaluate().isNotEmpty ||
          find.text('Markを追加').evaluate().isNotEmpty ||
          find.text('Mark を追加').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // BottomSheet が表示されること（Mark/Link 選択）
    final hasAddMark = find.text('地点を追加').evaluate().isNotEmpty ||
        find.text('Markを追加').evaluate().isNotEmpty ||
        find.text('Mark を追加').evaluate().isNotEmpty;
    final hasAddLink = find.text('区間を追加').evaluate().isNotEmpty ||
        find.text('Linkを追加').evaluate().isNotEmpty ||
        find.text('Link を追加').evaluate().isNotEmpty ||
        find.text('リンクを追加').evaluate().isNotEmpty;

    expect(
      hasAddMark || hasAddLink,
      isTrue,
      reason: '先頭インジケータータップ後にBottomSheet（地点を追加 / 区間を追加）が表示されること',
    );

    // BottomSheet で「地点を追加」を選択して MarkDetail へ遷移する
    Finder addMarkFinder;
    if (find.text('地点を追加').evaluate().isNotEmpty) {
      addMarkFinder = find.text('地点を追加');
    } else if (find.textContaining('Mark').evaluate().isNotEmpty) {
      addMarkFinder = find.textContaining('Mark');
    } else {
      markTestSkipped('TC-MIB-004: BottomSheetに地点追加ボタンが見つからないためスキップ');
      return;
    }

    await tester.tap(addMarkFinder.first);

    // MarkDetail 画面に遷移すること
    final reached = await waitForMarkDetailScreen(tester);
    expect(
      reached,
      isTrue,
      reason: '先頭インジケータータップ後にMarkDetail新規作成画面へ遷移すること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-MIB-005: カード間インジケーターをタップすると挿入フローが起動すること
  // ────────────────────────────────────────────────────────
  testWidgets('TC-MIB-005: カード間インジケーターをタップすると挿入フローが起動すること',
      (tester) async {
    await goToMichiInfoTab(tester);

    // FABをタップして InsertMode を ON にする
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget, reason: 'FABが表示されること');
    await tester.tap(fab);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byIcon(Icons.add_circle).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // カード間インジケーターが存在することを確認
    // michiInfo_button_insertIndicator_head 以外のインジケーターを探す
    // add_circle アイコンが2件以上存在し、2番目以降がカード間インジケーター
    final allIndicators = find.byIcon(Icons.add_circle);
    expect(
      allIndicators,
      findsWidgets,
      reason: 'InsertMode ON 時にインジケーターが複数表示されること',
    );

    final indicatorCount = allIndicators.evaluate().length;
    if (indicatorCount < 2) {
      markTestSkipped('TC-MIB-005: カード間インジケーターが見つからないためスキップ（2件未満）');
      return;
    }

    // 2番目のインジケーター（先頭カードと2番目カードの間）をタップ
    await tester.ensureVisible(allIndicators.at(1));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(allIndicators.at(1));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('地点を追加').evaluate().isNotEmpty ||
          find.text('Markを追加').evaluate().isNotEmpty ||
          find.text('Mark を追加').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // BottomSheet が表示されること
    final hasAddMark = find.text('地点を追加').evaluate().isNotEmpty ||
        find.text('Markを追加').evaluate().isNotEmpty ||
        find.text('Mark を追加').evaluate().isNotEmpty;
    final hasAddLink = find.text('区間を追加').evaluate().isNotEmpty ||
        find.text('Linkを追加').evaluate().isNotEmpty ||
        find.text('Link を追加').evaluate().isNotEmpty ||
        find.text('リンクを追加').evaluate().isNotEmpty;

    expect(
      hasAddMark || hasAddLink,
      isTrue,
      reason: 'カード間インジケータータップ後にBottomSheet（地点を追加 / 区間を追加）が表示されること',
    );

    // BottomSheet で「地点を追加」を選択して MarkDetail へ遷移する
    Finder addMarkFinder;
    if (find.text('地点を追加').evaluate().isNotEmpty) {
      addMarkFinder = find.text('地点を追加');
    } else if (find.textContaining('Mark').evaluate().isNotEmpty) {
      addMarkFinder = find.textContaining('Mark');
    } else {
      markTestSkipped('TC-MIB-005: BottomSheetに地点追加ボタンが見つからないためスキップ');
      return;
    }

    await tester.tap(addMarkFinder.first);

    // MarkDetail 画面に遷移すること
    final reached = await waitForMarkDetailScreen(tester);
    expect(
      reached,
      isTrue,
      reason: 'カード間インジケータータップ後にMarkDetail新規作成画面へ遷移すること',
    );
  });
}
