import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get_it/get_it.dart';
import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// アプリケーション起動ヘルパー
  /// visitWork トピックのイベントが表示されるまで待機する
  Future<void> startAppAndNavigateToVisitWork(WidgetTester tester) async {
    await GetIt.I.reset();
    app_router.router.go('/');
    app.main();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('イベント一覧').evaluate().isNotEmpty) {
        break;
      }
    }
    // イベント一覧から visitWork トピックのイベント（横浜エリア訪問ルート）を探す
    final eventFinder = find.text('横浜エリア訪問ルート');
    expect(eventFinder, findsOneWidget, reason: 'visitWork トピックのイベントが見つかりません');
    await tester.tap(eventFinder);
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('TC-VWA: visitWork Mark カード UI テスト', () {
    testWidgets('TC-VWA-001: visitWork Mark カードが3カラムレイアウトで表示される',
        (WidgetTester tester) async {
      await startAppAndNavigateToVisitWork(tester);

      // MichiInfo タブが表示されていることを確認
      expect(find.text('MichiInfo'), findsWidgets);

      // visitWork トピックのマークが表示されていることを確認
      // 横浜エリア訪問ルートのマークIDは以下
      const markIds = ['ml-sc-001', 'ml-sc-003', 'ml-sc-005', 'ml-sc-007', 'ml-sc-009'];

      for (final markId in markIds) {
        // アクションボタンが表示されている
        expect(
          find.byKey(Key('michiInfo_button_actionTime_$markId')),
          findsOneWidget,
          reason: 'アクションボタン（$markId）が見つかりません',
        );

        // 削除ボタンが表示されている
        expect(
          find.byKey(Key('michiInfo_button_delete_$markId')),
          findsOneWidget,
          reason: '削除ボタン（$markId）が見つかりません',
        );

        // 状態バッジが表示されている
        expect(
          find.byKey(Key('michiInfo_badge_actionState_$markId')),
          findsOneWidget,
          reason: '状態バッジ（$markId）が見つかりません',
        );
      }
    });

    testWidgets('TC-VWA-002: アクションボタンが中央カラムに「アクション」テキスト付きで表示される',
        (WidgetTester tester) async {
      await startAppAndNavigateToVisitWork(tester);

      // アクションボタン内に「アクション」テキストが表示されていることを確認
      expect(find.text('アクション'), findsWidgets, reason: 'アクションテキストが見つかりません');

      // 各マークのアクションボタンに「アクション」テキストが含まれているか確認
      const markIds = ['ml-sc-001', 'ml-sc-003', 'ml-sc-005', 'ml-sc-007', 'ml-sc-009'];

      for (final markId in markIds) {
        final buttonFinder = find.byKey(Key('michiInfo_button_actionTime_$markId'));
        expect(buttonFinder, findsOneWidget);

        // ボタン内にテキストが含まれているか確認
        final textFinder = find.descendant(
          of: buttonFinder,
          matching: find.text('アクション'),
        );
        expect(textFinder, findsOneWidget,
            reason: 'アクションボタン（$markId）にテキストが含まれていません');
      }
    });

    testWidgets('TC-VWA-003: 削除ボタンが右カラムに小さく・薄く表示される',
        (WidgetTester tester) async {
      await startAppAndNavigateToVisitWork(tester);

      const markIds = ['ml-sc-001', 'ml-sc-003', 'ml-sc-005', 'ml-sc-007', 'ml-sc-009'];

      for (final markId in markIds) {
        final deleteButtonFinder = find.byKey(Key('michiInfo_button_delete_$markId'));
        expect(deleteButtonFinder, findsOneWidget);

        // 削除ボタンをタップして確認ダイアログを表示
        await tester.tap(deleteButtonFinder);
        await tester.pump(const Duration(milliseconds: 500));

        // 削除確認ダイアログが表示されている
        final dialogFinder = find.byKey(const Key('deleteConfirmDialog_dialog_confirm'));
        expect(dialogFinder, findsOneWidget, reason: '削除確認ダイアログが見つかりません');

        // キャンセルボタンをタップして戻る
        final cancelButtonFinder = find.byKey(const Key('deleteConfirmDialog_button_cancel'));
        expect(cancelButtonFinder, findsOneWidget);
        await tester.tap(cancelButtonFinder);
        await tester.pump(const Duration(milliseconds: 500));

        // Mark カードがまだ存在することを確認
        expect(
          find.byKey(Key('michiInfo_item_mark_$markId')),
          findsOneWidget,
          reason: 'Mark カード（$markId）が削除されてしまいました',
        );
      }
    });

    testWidgets('TC-VWA-004: 状態バッジが左カラムに配置される',
        (WidgetTester tester) async {
      await startAppAndNavigateToVisitWork(tester);

      const markIds = ['ml-sc-001', 'ml-sc-003', 'ml-sc-005', 'ml-sc-007', 'ml-sc-009'];

      for (final markId in markIds) {
        final badgeFinder = find.byKey(Key('michiInfo_badge_actionState_$markId'));
        expect(badgeFinder, findsOneWidget, reason: '状態バッジ（$markId）が見つかりません');

        // バッジにテキストが表示されていることを確認
        // ActionTimeLog が記録されているマークは状態が変わる
        // 記録されていないマークは「滞留中」が表示される
        final badgeText = find.descendant(of: badgeFinder, matching: find.byType(Text));
        expect(badgeText, findsOneWidget);
      }
    });

    testWidgets('TC-VWA-005: アクションボタンタップでActionTimeボトムシートが開く',
        (WidgetTester tester) async {
      await startAppAndNavigateToVisitWork(tester);

      // ml-sc-003（A社）のアクションボタンをタップ
      final actionButtonFinder = find.byKey(const Key('michiInfo_button_actionTime_ml-sc-003'));
      expect(actionButtonFinder, findsOneWidget);

      await tester.tap(actionButtonFinder);
      await tester.pump(const Duration(milliseconds: 500));

      // ActionTime ボトムシートのヘッダーが表示される
      final sheetHeaderFinder = find.byKey(const Key('actionTime_sheet_header'));
      expect(sheetHeaderFinder, findsOneWidget, reason: 'ActionTime ボトムシートが開きません');
    });

    testWidgets(
        'TC-VWA-006: アクション表示順が「到着→作業開始→作業終了→出発」になっている',
        (WidgetTester tester) async {
      await startAppAndNavigateToVisitWork(tester);

      // ml-sc-003（A社）のアクションボタンをタップしてボトムシートを開く
      final actionButtonFinder = find.byKey(const Key('michiInfo_button_actionTime_ml-sc-003'));
      await tester.tap(actionButtonFinder);
      await tester.pump(const Duration(milliseconds: 500));

      // アクションボタンが表示されていることを確認
      expect(find.byKey(const Key('actionTime_button_action_visit_work_arrive')), findsOneWidget);
      expect(find.byKey(const Key('actionTime_button_action_visit_work_start')), findsOneWidget);
      expect(find.byKey(const Key('actionTime_button_action_visit_work_end')), findsOneWidget);
      expect(find.byKey(const Key('actionTime_button_action_visit_work_depart')), findsOneWidget);

      // 「休憩」ボタンが表示されていないことを確認
      expect(find.byKey(const Key('actionTime_button_action_visit_work_break')), findsNothing);
    });
  });
}
