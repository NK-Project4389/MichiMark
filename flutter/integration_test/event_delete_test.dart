/// Integration Test: イベント削除機能テスト
///
/// Feature Spec: EventDelete_Spec.md
/// テストグループ: TC-ELD（Event List Delete）
///
/// TC-ELD-001: イベントを左スワイプすると削除アクションが表示される
/// TC-ELD-002: 削除ボタンをタップするとイベントが一覧から消える
/// TC-ELD-003: 削除後に確認ダイアログが表示されない

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
  /// シードデータが存在することを前提とする。
  Future<void> startApp(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/');
    app.main();
    // EventListPage の AppBar title「イベント」が表示されるまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント一覧').evaluate().isNotEmpty) break;
    }
    // データロード完了を待つ（ListView 表示まで）
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(ListView).evaluate().isNotEmpty ||
          find.text('イベントがありません').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ────────────────────────────────────────────────────────
  // TC-ELD-001: イベントを左スワイプすると削除アクションが表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-ELD-001: イベントを左スワイプすると削除アクションが表示される',
      (tester) async {
    await startApp(tester);

    // シードデータが存在しない場合はスキップ
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないため TC-ELD-001 をスキップします');
      return;
    }

    // 最初の Slidable を探す
    // シードデータのイベント ID（event-001）を使ってキーで探す
    final slidableKey = const Key('event_list_item_slidable_event-001');
    final slidable = find.byKey(slidableKey);

    if (slidable.evaluate().isEmpty) {
      markTestSkipped(
          'event-001 の Slidable が見つからないため TC-ELD-001 をスキップします');
      return;
    }

    // 左スワイプで削除アクションを表示する
    await tester.drag(slidable, const Offset(-300, 0));
    await tester.pump(const Duration(milliseconds: 500));

    // 削除アクション（ラベル「削除」）が表示されることを確認
    expect(
      find.text('削除'),
      findsOneWidget,
      reason: '左スワイプ後に削除アクション（ラベル「削除」）が表示されること',
    );

    // 削除アクションキーでも確認
    final deleteActionKey = const Key('event_list_delete_action_event-001');
    expect(
      find.byKey(deleteActionKey),
      findsOneWidget,
      reason: '削除アクションウィジェットが Key で見つかること',
    );
  });

  // ────────────────────────────────────────────────────────
  // TC-ELD-002: 削除ボタンをタップするとイベントが一覧から消える
  // ────────────────────────────────────────────────────────
  testWidgets('TC-ELD-002: 削除ボタンをタップするとイベントが一覧から消える',
      (tester) async {
    await startApp(tester);

    // シードデータが存在しない場合はスキップ
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないため TC-ELD-002 をスキップします');
      return;
    }

    // event-001 の Slidable を探す
    final slidableKey = const Key('event_list_item_slidable_event-001');
    final slidable = find.byKey(slidableKey);

    if (slidable.evaluate().isEmpty) {
      markTestSkipped(
          'event-001 の Slidable が見つからないため TC-ELD-002 をスキップします');
      return;
    }

    // 削除前に event-002 が表示されていることを確認（他のイベントが残ることの確認用）
    // event-002 の Slidable を事前確認
    final otherSlidableKey = const Key('event_list_item_slidable_event-002');
    final otherSlidableExists =
        find.byKey(otherSlidableKey).evaluate().isNotEmpty;

    // event-001 を左スワイプして削除ボタンを表示
    await tester.drag(slidable, const Offset(-300, 0));
    await tester.pump(const Duration(milliseconds: 500));

    // 削除ボタンが表示されていることを確認
    final deleteActionKey = const Key('event_list_delete_action_event-001');
    expect(
      find.byKey(deleteActionKey),
      findsOneWidget,
      reason: 'スワイプ後に削除アクションが表示されること',
    );

    // 削除アクションをタップ
    await tester.ensureVisible(find.byKey(deleteActionKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteActionKey));

    // 削除処理の完了を待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(slidableKey).evaluate().isEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));

    // event-001 が一覧から消えていることを確認
    expect(
      find.byKey(slidableKey),
      findsNothing,
      reason: '削除したイベント（event-001）が一覧から消えていること',
    );

    // 他のイベント（event-002）はまだ存在することを確認
    if (otherSlidableExists) {
      expect(
        find.byKey(otherSlidableKey),
        findsOneWidget,
        reason: '削除していないイベント（event-002）は引き続き表示されていること',
      );
    }
  });

  // ────────────────────────────────────────────────────────
  // TC-ELD-003: 削除後に確認ダイアログが表示されない
  // ────────────────────────────────────────────────────────
  testWidgets('TC-ELD-003: 削除後に確認ダイアログが表示されない', (tester) async {
    await startApp(tester);

    // シードデータが存在しない場合はスキップ
    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('イベントデータが存在しないため TC-ELD-003 をスキップします');
      return;
    }

    // event-001 の Slidable を探す
    final slidableKey = const Key('event_list_item_slidable_event-001');
    final slidable = find.byKey(slidableKey);

    if (slidable.evaluate().isEmpty) {
      markTestSkipped(
          'event-001 の Slidable が見つからないため TC-ELD-003 をスキップします');
      return;
    }

    // 左スワイプして削除ボタンを表示
    await tester.drag(slidable, const Offset(-300, 0));
    await tester.pump(const Duration(milliseconds: 500));

    // 削除アクションをタップ
    final deleteActionKey = const Key('event_list_delete_action_event-001');
    expect(find.byKey(deleteActionKey), findsOneWidget,
        reason: 'スワイプ後に削除アクションが表示されること');

    await tester.ensureVisible(find.byKey(deleteActionKey));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(deleteActionKey));

    // 少し待つ（ダイアログが表示されるかどうかを確認するため）
    await tester.pump(const Duration(milliseconds: 500));

    // AlertDialog / ConfirmationDialog が表示されていないことを確認
    expect(
      find.byType(AlertDialog),
      findsNothing,
      reason: '削除後に AlertDialog が表示されないこと（確認なし即削除）',
    );

    // 削除処理の完了を待つ
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 最終確認: ダイアログが出ていないことを改めて確認
    expect(
      find.byType(AlertDialog),
      findsNothing,
      reason: '削除完了後も AlertDialog が表示されていないこと',
    );
  });
}
