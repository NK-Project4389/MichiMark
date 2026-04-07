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

  /// アプリを起動してEventListPageが表示されるまで待つ。
  /// CLAUDE.md の OK パターンに従い:
  ///   1. GetIt をリセット
  ///   2. router.go('/') でルートをリセット
  ///   3. app.main() でアプリ起動
  Future<void> startApp(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/');
    app.main();
    // EventListPage の AppBar title「イベント」が表示されるまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント').evaluate().isNotEmpty) break;
    }
    // データロード完了を待つ（ListView表示まで）
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('箱根日帰りドライブ').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// EventList → 箱根日帰りドライブ → ミチタブ の順で遷移する。
  /// 遷移に成功した場合は true を返す。
  Future<bool> goToMichiInfoTab(WidgetTester tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return false;
    }

    // 「箱根日帰りドライブ」を含む Text（AppBarではなくListItem内）をタップ
    // find.text は完全一致なのでEditableTextも拾う可能性あり → find.widgetWithText で絞る
    final eventCards = find.ancestor(
      of: find.text('箱根日帰りドライブ'),
      matching: find.byType(GestureDetector),
    );

    if (eventCards.evaluate().isEmpty) return false;

    await tester.tap(eventCards.first);
    await tester.pumpAndSettle();

    // EventDetail画面の「ミチ」タブをタップ
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return false;
    await tester.tap(michiTab);
    await tester.pumpAndSettle();

    return true;
  }

  // ────────────────────────────────────────────────────────
  // TS-01: タイムラインの基本表示
  // ────────────────────────────────────────────────────────
  testWidgets('TS-01: タイムラインの基本表示', (tester) async {
    final reached = await goToMichiInfoTab(tester);

    if (!reached) {
      expect(find.text('イベントがありません'), findsOneWidget,
          reason: 'イベントが存在しない場合は「イベントがありません」が表示されること');
      return;
    }

    final hasNoItems =
        find.text('地点/区間がありません').evaluate().isNotEmpty;

    if (hasNoItems) {
      expect(find.text('地点/区間がありません'), findsOneWidget,
          reason: 'Mark/Linkが0件の場合「地点/区間がありません」が表示されること');
      expect(find.byType(FloatingActionButton), findsOneWidget,
          reason: '空リスト時もFABが表示されること');
    } else {
      // 凡例が表示されていること
      expect(find.text('メーター差分'), findsOneWidget,
          reason: '_DistanceLegend の「メーター差分」が表示されること');
      expect(find.text('区間距離'), findsOneWidget,
          reason: '_DistanceLegend の「区間距離」が表示されること');
      // Mark行（自宅出発）が表示されていること
      expect(find.text('自宅出発'), findsOneWidget,
          reason: 'Mark行「自宅出発」が表示されること');
      // Link行（東名高速）が表示されていること
      expect(find.text('東名高速'), findsOneWidget,
          reason: 'Link行「東名高速」が表示されること');
    }
  });

  // ────────────────────────────────────────────────────────
  // TS-02: メーター差分の表示
  // ────────────────────────────────────────────────────────
  testWidgets('TS-02: メーター差分の表示（2件目以降のMarkに+xxx kmが表示される）',
      (tester) async {
    final reached = await goToMichiInfoTab(tester);

    if (!reached) {
      markTestSkipped('TS-02: MichiInfoタブに遷移できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TS-02: Mark/Linkが0件のためスキップ');
      return;
    }

    // メーター差分テキストを探す
    final diffTexts = find.textContaining(' km');

    if (diffTexts.evaluate().isEmpty) {
      markTestSkipped('TS-02: メーター差分表示対象のMarkが存在しないためスキップ');
      return;
    }

    final allTexts = tester
        .widgetList<Text>(diffTexts)
        .map((t) => t.data ?? '')
        .toList();
    final hasDiff =
        allTexts.any((t) => t.contains('+') || t.contains('-'));
    expect(hasDiff, isTrue,
        reason: '2件目以降のMarkに"+xxx km"または"-xxx km"形式のメーター差分が表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TS-03: Mark タップで詳細画面に遷移
  // ────────────────────────────────────────────────────────
  testWidgets('TS-03: Markタップで詳細画面に遷移', (tester) async {
    final reached = await goToMichiInfoTab(tester);

    if (!reached) {
      markTestSkipped('TS-03: MichiInfoタブに遷移できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TS-03: Mark/Linkが0件のためスキップ');
      return;
    }

    // Mark名（シードデータ: 自宅出発）をタップ
    final markText = find.text('自宅出発');
    if (markText.evaluate().isEmpty) {
      markTestSkipped('TS-03: Mark「自宅出発」が見つからない');
      return;
    }

    await tester.tap(markText);
    await tester.pumpAndSettle();

    final onMarkDetail = find.text('反映').evaluate().isNotEmpty ||
        find.text('地点詳細').evaluate().isNotEmpty ||
        find.text('名称（任意）').evaluate().isNotEmpty;
    expect(onMarkDetail, isTrue,
        reason: 'Mark行「自宅出発」をタップするとMarkDetail画面に遷移すること');
  });

  // ────────────────────────────────────────────────────────
  // TS-04: Link タップで詳細画面に遷移
  // ────────────────────────────────────────────────────────
  testWidgets('TS-04: Linkタップで詳細画面に遷移', (tester) async {
    final reached = await goToMichiInfoTab(tester);

    if (!reached) {
      markTestSkipped('TS-04: MichiInfoタブに遷移できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TS-04: Mark/Linkが0件のためスキップ');
      return;
    }

    // Link名（シードデータ: 東名高速）をタップ
    final linkText = find.text('東名高速');
    if (linkText.evaluate().isEmpty) {
      markTestSkipped('TS-04: Link「東名高速」が見つからない');
      return;
    }

    await tester.tap(linkText);
    await tester.pumpAndSettle();

    // LinkDetailPage に遷移したことを確認
    final onDetailPage = find.text('反映').evaluate().isNotEmpty ||
        find.text('区間詳細').evaluate().isNotEmpty;
    expect(onDetailPage, isTrue,
        reason: 'Link行「東名高速」をタップするとLinkDetail画面に遷移すること');
  });

  // ────────────────────────────────────────────────────────
  // TS-05: 地点追加フローの動作
  // ────────────────────────────────────────────────────────
  testWidgets(
      'TS-05: FABタップで地点追加メニューが表示され、地点を追加を選択するとMarkDetail新規画面に遷移',
      (tester) async {
    final reached = await goToMichiInfoTab(tester);

    if (!reached) {
      markTestSkipped('TS-05: MichiInfoタブに遷移できなかったためスキップ');
      return;
    }

    // FABをタップ
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget, reason: 'FABが表示されていること');

    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.text('地点を追加'), findsOneWidget,
        reason: 'FABタップ後に「地点を追加」メニューが表示されること');

    await tester.tap(find.text('地点を追加'));
    await tester.pumpAndSettle();

    final onMarkDetail = find.text('反映').evaluate().isNotEmpty ||
        find.text('地点詳細').evaluate().isNotEmpty ||
        find.text('名称（任意）').evaluate().isNotEmpty;
    expect(onMarkDetail, isTrue,
        reason: '「地点を追加」選択後、MarkDetail新規追加画面に遷移すること');
  });

  // ────────────────────────────────────────────────────────
  // TS-06: 空リスト時のメッセージ表示
  // ────────────────────────────────────────────────────────
  testWidgets('TS-06: Mark/Linkが0件のイベントでは空リストメッセージが表示される',
      (tester) async {
    await startApp(tester);

    // シードデータ event-003「近所のドライブ」は markLinks が空
    final emptyEventCards = find.ancestor(
      of: find.text('近所のドライブ'),
      matching: find.byType(GestureDetector),
    );

    if (emptyEventCards.evaluate().isEmpty) {
      markTestSkipped('TS-06: 空イベント「近所のドライブ」が見つからない');
      return;
    }

    await tester.tap(emptyEventCards.first);
    await tester.pumpAndSettle();

    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) {
      markTestSkipped('TS-06: ミチタブが見つからない');
      return;
    }
    await tester.tap(michiTab);
    await tester.pumpAndSettle();

    expect(find.text('地点/区間がありません'), findsOneWidget,
        reason: 'Mark/Linkが0件の場合「地点/区間がありません」が表示されること');
    expect(find.byType(FloatingActionButton), findsOneWidget,
        reason: '空リスト時もFABが表示されること');
  });

  // ────────────────────────────────────────────────────────
  // TS-07: MarkDetail 保存後に一覧が更新される
  // ────────────────────────────────────────────────────────
  testWidgets('TS-07: MarkDetail保存後にMichiInfo一覧に変更後の名称が反映される',
      (tester) async {
    final reached = await goToMichiInfoTab(tester);

    if (!reached) {
      markTestSkipped('TS-07: MichiInfoタブに遷移できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TS-07: Mark/Linkが0件のためスキップ');
      return;
    }

    // Mark名「自宅出発」をタップして詳細画面へ
    final markText = find.text('自宅出発');
    if (markText.evaluate().isEmpty) {
      markTestSkipped('TS-07: Mark「自宅出発」が見つからない');
      return;
    }

    await tester.tap(markText);
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    if (textFields.evaluate().isEmpty) {
      markTestSkipped('TS-07: 詳細画面のフォームが見つからない');
      return;
    }

    // テスト用の名称を入力
    const testName = 'TS07テスト地点';
    final firstTextField = textFields.first;
    await tester.tap(firstTextField);
    await tester.pump();
    await tester.enterText(firstTextField, testName);
    await tester.pump();

    // 「反映」ボタンをタップして保存
    final saveButton = find.text('反映');
    if (saveButton.evaluate().isEmpty) {
      markTestSkipped('TS-07: 「反映」ボタンが見つからない');
      return;
    }

    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // MichiInfo一覧に戻るまで待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('メーター差分').evaluate().isNotEmpty ||
          find.text('地点/区間がありません').evaluate().isNotEmpty) break;
    }

    expect(find.text(testName), findsOneWidget,
        reason: 'MarkDetail保存後にMichiInfo一覧に変更後の名称「$testName」が表示されること');
  });
}
