/// Integration Test: EventListのリロード確認テスト
///
/// 修正内容: _handleDelegate で context.push('/event/$eventId').then((_) { bloc.add(EventListStarted()) }) を追加
/// 確認内容:
///   TC-BUG-001: EventDetailでイベント名変更・保存後、EventListに戻ったとき変更名が反映されること
///   TC-BUG-002: 新規イベント作成後、EventListに戻ったときリストに追加されること

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
      if (find.byType(ListView).evaluate().isNotEmpty ||
          find.text('イベントがありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ────────────────────────────────────────────────────────
  // TC-BUG-001: EventDetailでイベント名変更・保存後、EventListに戻ったとき変更名が反映される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-BUG-001: EventDetail保存後にEventListへ戻ったとき変更が反映されること',
      (tester) async {
    await startApp(tester);

    // イベントが存在しない場合はスキップ
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないためTC-BUG-001をスキップします');
      return;
    }

    // 最初のGestureDetectorをタップしてEventDetailへ遷移
    final listView = find.byType(ListView);
    if (listView.evaluate().isEmpty) {
      markTestSkipped('ListViewが見つからないためTC-BUG-001をスキップします');
      return;
    }

    final gestureDetectors = find.descendant(
      of: listView,
      matching: find.byType(GestureDetector),
    );
    if (gestureDetectors.evaluate().isEmpty) {
      markTestSkipped('イベントアイテムが見つからないためTC-BUG-001をスキップします');
      return;
    }

    await tester.tap(gestureDetectors.first);
    await tester.pumpAndSettle();

    // EventDetail画面に遷移したことを確認（chevron_leftのBackボタンが表示される）
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byIcon(Icons.chevron_left).evaluate().isNotEmpty) break;
    }

    // EventDetail画面にいることを確認
    expect(find.byIcon(Icons.chevron_left), findsOneWidget,
        reason: 'EventDetail画面に遷移できていること');

    // イベント名入力フィールド（labelText: 'イベント名'）を探してテキストを変更する
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isEmpty) {
      markTestSkipped('イベント名TextFieldが見つからないためTC-BUG-001をスキップします');
      return;
    }

    // 最初のTextField（イベント名）を変更する
    const newEventName = 'テスト変更イベント名_BUG001';
    await tester.tap(textFields.first);
    await tester.pumpAndSettle();
    await tester.enterText(textFields.first, newEventName);
    await tester.pumpAndSettle();

    // 保存ボタン（Icons.check）をタップ
    final checkButton = find.byIcon(Icons.check);
    expect(checkButton, findsOneWidget,
        reason: 'EventDetail画面に保存ボタン（チェックアイコン）が存在すること');

    await tester.ensureVisible(checkButton);
    await tester.pumpAndSettle();
    await tester.tap(checkButton);
    await tester.pumpAndSettle();

    // 「保存しました」スナックバーが表示されることを確認
    expect(find.text('保存しました'), findsOneWidget,
        reason: '保存後に「保存しました」スナックバーが表示されること');

    // 戻るボタン（chevron_left）をタップしてEventListに戻る
    final backButton = find.byIcon(Icons.chevron_left);
    await tester.tap(backButton.first);

    // EventListが再ロードされるまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント').evaluate().isNotEmpty) break;
    }
    await tester.pumpAndSettle();

    // EventListに変更したイベント名が表示されることを確認
    expect(find.text(newEventName), findsOneWidget,
        reason:
            'EventDetailで変更・保存したイベント名「$newEventName」がEventListに反映されること（バグ修正確認）');
  });

  // ────────────────────────────────────────────────────────
  // TC-BUG-002: 新規イベント作成後、EventListに戻ったときリストに追加される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-BUG-002: 新規イベント作成後にEventListへ戻ったときリストに追加されること',
      (tester) async {
    await startApp(tester);

    // 現在のリスト件数を取得
    int getItemCount() {
      final listView = find.byType(ListView);
      if (listView.evaluate().isEmpty) return 0;
      return find
          .descendant(
            of: listView.first,
            matching: find.byType(GestureDetector),
          )
          .evaluate()
          .length;
    }

    final initialItemCount = getItemCount();

    // FABをタップしてTopicSelectionSheetを表示
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget, reason: 'EventList画面にFABが表示されること');

    await tester.tap(fab);
    await tester.pumpAndSettle();

    // TopicSelectionSheetが表示されることを確認
    expect(find.text('トピックを選択'), findsOneWidget,
        reason: 'FABタップ後にトピック選択シートが表示されること');

    // 最初のTopicTypeをタップ（ListTileの先頭をタップ）
    final topicListTiles = find.byType(ListTile);
    expect(topicListTiles, findsWidgets,
        reason: 'TopicSelectionSheetにTopicタイプの選択肢が表示されること');

    await tester.tap(topicListTiles.first);
    await tester.pumpAndSettle();

    // EventDetail画面が表示されるまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byIcon(Icons.chevron_left).evaluate().isNotEmpty) break;
    }
    await tester.pumpAndSettle();

    // EventDetail画面にいることを確認
    expect(find.byIcon(Icons.chevron_left), findsOneWidget,
        reason: 'トピック選択後にEventDetail画面に遷移できること');

    // 戻るボタン（chevron_left）をタップしてEventListに戻る
    final backButton = find.byIcon(Icons.chevron_left);
    await tester.tap(backButton.first);

    // EventListが再ロードされるまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント').evaluate().isNotEmpty) break;
    }
    await tester.pumpAndSettle();

    // EventListに戻っていることを確認
    expect(find.text('イベント'), findsOneWidget,
        reason: 'EventListに戻れること');

    // リスト件数が増えていることを確認
    final updatedItemCount = getItemCount();

    expect(updatedItemCount, greaterThan(initialItemCount),
        reason:
            '新規イベント作成後にEventListへ戻ったとき、リスト件数が増えていること（バグ修正確認）。'
            '修正前: $initialItemCount件 → 修正後: $updatedItemCount件');
  });
}
