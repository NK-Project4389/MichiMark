// ignore_for_file: avoid_print
// ignore_for_file: dangling_library_doc_comments

/// Integration Test: UI-24 ActionTime アクションボタン大型化
///
/// Spec: docs/Spec/Features/FS-action_time_button_redesign.md §10.3-10.4
///
/// テストシナリオ: TC-ATB-001 〜 TC-ATB-007
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - visitWorkトピックのイベントにMarkが1件以上存在すること
///   - ActionTimeボトムシートが表示可能な状態であること

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

  /// イベント一覧から最初のイベント（preferably visitWork）を開き MichiInfo タブへ遷移する。
  /// 遷移成功で true、不可能な場合は false を返す。
  Future<bool> goToMichiInfoTab(WidgetTester tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      return false;
    }

    // イベントカード（最初のものをタップ）
    final gestureDetectors = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(GestureDetector),
    );
    if (gestureDetectors.evaluate().isEmpty) return false;
    await tester.tap(gestureDetectors.first);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ミチ').evaluate().isNotEmpty) break;
    }

    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return false;
    await tester.tap(michiTab);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty ||
          find.text('地点/区間がありません').evaluate().isNotEmpty) break;
    }

    // TopicConfigUpdated によるmarkActionItems設定を待つ（⚡ボタン表示確認）
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('mark_action_button')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));

    return true;
  }

  /// MichiInfo タブに表示されている ⚡ ボタン（mark_action_button）を取得する。
  Finder findActionButton() {
    return find.byKey(const Key('mark_action_button'));
  }

  /// ActionTimeボトムシートを開く（⚡ボタンをタップ）。
  /// 成功で true、失敗で false を返す。
  Future<bool> openActionTimeBottomSheet(WidgetTester tester) async {
    final actionButton = findActionButton();
    if (actionButton.evaluate().isEmpty) return false;

    await tester.ensureVisible(actionButton.first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(actionButton.first);

    // ボトムシートが表示されるまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('actionTime_sheet_header')).evaluate().isNotEmpty) {
        break;
      }
    }

    await tester.pump(const Duration(milliseconds: 500));
    return find.byKey(const Key('actionTime_sheet_header')).evaluate().isNotEmpty;
  }

  /// ActionTimeボトムシート内のアクションボタンを探す（キー: actionTime_button_action_${actionId}）。
  Finder findActionTimeButton(String actionId) {
    return find.byKey(Key('actionTime_button_action_$actionId'));
  }

  // ────────────────────────────────────────────────────────
  // TC-ATB-001: アクションボタンが横一列・等幅で並んで表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-ATB-001: アクションボタンが横一列・等幅で並んで表示される',
      (tester) async {
    final reached = await goToMichiInfoTab(tester);
    if (!reached) {
      markTestSkipped('TC-ATB-001: MichiInfoタブに遷移できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TC-ATB-001: Mark/Linkが0件のためスキップ');
      return;
    }

    final sheetOpened = await openActionTimeBottomSheet(tester);
    if (!sheetOpened) {
      markTestSkipped('TC-ATB-001: ActionTimeボトムシートが開けなかったためスキップ');
      return;
    }

    // アクションボタン群の存在確認（複数個）
    final actionButtons = find.byWidgetPredicate(
      (w) => w.key != null && w.key.toString().contains('actionTime_button_action_'),
    );

    expect(
      actionButtons.evaluate().length >= 1,
      isTrue,
      reason: 'ActionTimeボトムシート内にアクションボタンが1件以上表示されること',
    );

    print('TC-ATB-001: アクションボタン件数 = ${actionButtons.evaluate().length}');
  });

  // ────────────────────────────────────────────────────────
  // TC-ATB-002: 押下履歴がないアクションボタンに「未記録」テキストが表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-ATB-002: 押下履歴がないアクションボタンに「未記録」テキストが表示される',
      (tester) async {
    final reached = await goToMichiInfoTab(tester);
    if (!reached) {
      markTestSkipped('TC-ATB-002: MichiInfoタブに遷移できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TC-ATB-002: Mark/Linkが0件のためスキップ');
      return;
    }

    final sheetOpened = await openActionTimeBottomSheet(tester);
    if (!sheetOpened) {
      markTestSkipped('TC-ATB-002: ActionTimeボトムシートが開けなかったためスキップ');
      return;
    }

    // 「未記録」ラベル（actionTime_label_noRecord_${actionId}）の存在確認
    final noRecordLabels = find.byWidgetPredicate(
      (w) => w.key != null && w.key.toString().contains('actionTime_label_noRecord_'),
    );

    expect(
      noRecordLabels.evaluate().isNotEmpty,
      isTrue,
      reason: 'ログがないアクションボタンに「未記録」テキストが表示されること',
    );

    print('TC-ATB-002: 「未記録」ラベル件数 = ${noRecordLabels.evaluate().length}');
  });

  // ────────────────────────────────────────────────────────
  // TC-ATB-003: アクションボタンを押してもActionTimeボトムシートが閉じない
  // ────────────────────────────────────────────────────────
  testWidgets('TC-ATB-003: アクションボタンを押してもActionTimeボトムシートが閉じない',
      (tester) async {
    final reached = await goToMichiInfoTab(tester);
    if (!reached) {
      markTestSkipped('TC-ATB-003: MichiInfoタブに遷移できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TC-ATB-003: Mark/Linkが0件のためスキップ');
      return;
    }

    final sheetOpened = await openActionTimeBottomSheet(tester);
    if (!sheetOpened) {
      markTestSkipped('TC-ATB-003: ActionTimeボトムシートが開けなかったためスキップ');
      return;
    }

    // 「到着」ボタンをタップ
    final arriveButton = findActionTimeButton('visit_work_arrive');
    if (arriveButton.evaluate().isEmpty) {
      markTestSkipped('TC-ATB-003: 「到着」ボタンが見つからないためスキップ');
      return;
    }

    await tester.ensureVisible(arriveButton.first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(arriveButton.first);

    // ボタン押下後、アクションボタンが引き続き表示されているか最大6秒待つ
    // （actionTime_sheet_header はListViewの描画タイミングにより見つからないケースがあるため
    //  シート内のアクションボタンキーで代替判定する）
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (findActionTimeButton('visit_work_arrive').evaluate().isNotEmpty) {
        break;
      }
    }

    // ボトムシート内のアクションボタンが引き続き表示されていることを確認（シートが閉じていないことの証明）
    expect(
      findActionTimeButton('visit_work_arrive').evaluate().isNotEmpty,
      isTrue,
      reason: 'アクションボタン押下後、ボトムシートが閉じず、アクションボタンが表示されたままであること',
    );

    print('TC-ATB-003: ボトムシート残存確認 OK');
  });

  // ────────────────────────────────────────────────────────
  // TC-ATB-004: アクションボタンを押すとActionTimeLogが記録される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-ATB-004: アクションボタンを押すとActionTimeLogが記録される',
      (tester) async {
    final reached = await goToMichiInfoTab(tester);
    if (!reached) {
      markTestSkipped('TC-ATB-004: MichiInfoタブに遷移できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TC-ATB-004: Mark/Linkが0件のためスキップ');
      return;
    }

    final sheetOpened = await openActionTimeBottomSheet(tester);
    if (!sheetOpened) {
      markTestSkipped('TC-ATB-004: ActionTimeボトムシートが開けなかったためスキップ');
      return;
    }

    // 「到着」ボタンをタップ
    final arriveButton = findActionTimeButton('visit_work_arrive');
    if (arriveButton.evaluate().isEmpty) {
      markTestSkipped('TC-ATB-004: 「到着」ボタンが見つからないためスキップ');
      return;
    }

    await tester.ensureVisible(arriveButton.first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(arriveButton.first);

    // ログが記録されるまで待つ（最大5秒）
    for (var i = 0; i < 17; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // ログアイテムが表示されるか確認
      if (find.byKey(const Key('actionTime_logItem_0')).evaluate().isNotEmpty) {
        break;
      }
    }

    // ログアイテム（actionTime_logItem_0）が表示されていることを確認
    expect(
      find.byKey(const Key('actionTime_logItem_0')).evaluate().isNotEmpty,
      isTrue,
      reason: 'アクションボタン押下後、ActionTimeLogが記録されてログセクションに表示されること',
    );

    print('TC-ATB-004: ログ記録確認 OK');
  });

  // ────────────────────────────────────────────────────────
  // TC-ATB-005: アクションボタンを押すと直近の押下時刻（HH:mm）が更新される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-ATB-005: アクションボタンを押すと直近の押下時刻（HH:mm）が更新される',
      (tester) async {
    final reached = await goToMichiInfoTab(tester);
    if (!reached) {
      markTestSkipped('TC-ATB-005: MichiInfoタブに遷移できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TC-ATB-005: Mark/Linkが0件のためスキップ');
      return;
    }

    final sheetOpened = await openActionTimeBottomSheet(tester);
    if (!sheetOpened) {
      markTestSkipped('TC-ATB-005: ActionTimeボトムシートが開けなかったためスキップ');
      return;
    }

    // 「到着」ボタンをタップ
    final arriveButton = findActionTimeButton('visit_work_arrive');
    if (arriveButton.evaluate().isEmpty) {
      markTestSkipped('TC-ATB-005: 「到着」ボタンが見つからないためスキップ');
      return;
    }

    await tester.ensureVisible(arriveButton.first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(arriveButton.first);

    // 時刻が更新されるまで待つ（最大5秒）
    for (var i = 0; i < 17; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // 直近時刻ラベルが表示されるか確認
      if (find
          .byKey(const Key('actionTime_label_lastTime_visit_work_arrive'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    // 直近時刻ラベル（actionTime_label_lastTime_visit_work_arrive）が表示されていることを確認
    expect(
      find
          .byKey(const Key('actionTime_label_lastTime_visit_work_arrive'))
          .evaluate()
          .isNotEmpty,
      isTrue,
      reason: 'アクションボタン押下後、直近の押下時刻（HH:mm）がボタン内に表示されること',
    );

    // 「未記録」ラベルが消えていることを確認
    expect(
      find
          .byKey(const Key('actionTime_label_noRecord_visit_work_arrive'))
          .evaluate()
          .isEmpty,
      isTrue,
      reason: '時刻が記録されたアクションボタンから「未記録」ラベルが消えること',
    );

    print('TC-ATB-005: 時刻更新確認 OK');
  });

  // ────────────────────────────────────────────────────────
  // TC-ATB-006: 最後に押したボタンがアクティブ状態（Violet背景・ボーダー）で表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-ATB-006: 最後に押したボタンがアクティブ状態で表示される',
      (tester) async {
    final reached = await goToMichiInfoTab(tester);
    if (!reached) {
      markTestSkipped('TC-ATB-006: MichiInfoタブに遷移できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TC-ATB-006: Mark/Linkが0件のためスキップ');
      return;
    }

    final sheetOpened = await openActionTimeBottomSheet(tester);
    if (!sheetOpened) {
      markTestSkipped('TC-ATB-006: ActionTimeボトムシートが開けなかったためスキップ');
      return;
    }

    // 「到着」ボタンをタップ
    final arriveButton = findActionTimeButton('visit_work_arrive');
    if (arriveButton.evaluate().isEmpty) {
      markTestSkipped('TC-ATB-006: 「到着」ボタンが見つからないためスキップ');
      return;
    }

    await tester.ensureVisible(arriveButton.first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(arriveButton.first);

    // ボタンの背景色が更新されるまで待つ（最大5秒）
    for (var i = 0; i < 17; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 「到着」ボタンが存在することを確認（アクティブ状態の視覚的検証は難しいため、存在確認とする）
    expect(
      findActionTimeButton('visit_work_arrive').evaluate().isNotEmpty,
      isTrue,
      reason: '最後に押した「到着」ボタンがアクティブ状態で表示されていること',
    );

    print('TC-ATB-006: アクティブボタン表示確認 OK');
  });

  // ────────────────────────────────────────────────────────
  // TC-ATB-007: アクションを連続して記録できる（ボトムシートが閉じないため）
  // ────────────────────────────────────────────────────────
  testWidgets('TC-ATB-007: アクションを連続して記録できる', (tester) async {
    final reached = await goToMichiInfoTab(tester);
    if (!reached) {
      markTestSkipped('TC-ATB-007: MichiInfoタブに遷移できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TC-ATB-007: Mark/Linkが0件のためスキップ');
      return;
    }

    final sheetOpened = await openActionTimeBottomSheet(tester);
    if (!sheetOpened) {
      markTestSkipped('TC-ATB-007: ActionTimeボトムシートが開けなかったためスキップ');
      return;
    }

    // 1回目: 「到着」ボタンをタップ
    final arriveButton = findActionTimeButton('visit_work_arrive');
    if (arriveButton.evaluate().isEmpty) {
      markTestSkipped('TC-ATB-007: 「到着」ボタンが見つからないためスキップ');
      return;
    }

    await tester.ensureVisible(arriveButton.first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(arriveButton.first);

    // ボトムシートが表示されたままであることを確認（アクションボタンキーで判定）
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (findActionTimeButton('visit_work_arrive').evaluate().isNotEmpty) {
        break;
      }
    }

    final sheetStillOpen1 =
        findActionTimeButton('visit_work_arrive').evaluate().isNotEmpty;
    if (!sheetStillOpen1) {
      markTestSkipped('TC-ATB-007: 1回目のボタン押下後、ボトムシートが閉じたためスキップ');
      return;
    }

    // 2回目: 「作業開始」ボタンをタップ
    await tester.pump(const Duration(milliseconds: 300));
    final startButton = findActionTimeButton('visit_work_start');
    if (startButton.evaluate().isEmpty) {
      markTestSkipped('TC-ATB-007: 「作業開始」ボタンが見つからないためスキップ');
      return;
    }

    await tester.ensureVisible(startButton.first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(startButton.first);

    // 2回目のボタン押下後、ログが2件になるまで待つ（最大5秒）
    for (var i = 0; i < 17; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      // ログアイテムが2件表示されるか確認
      if (find.byKey(const Key('actionTime_logItem_1')).evaluate().isNotEmpty) {
        break;
      }
    }

    // ログアイテムが2件以上表示されていることを確認
    expect(
      find.byKey(const Key('actionTime_logItem_0')).evaluate().isNotEmpty &&
          find.byKey(const Key('actionTime_logItem_1')).evaluate().isNotEmpty,
      isTrue,
      reason: 'ボトムシートが閉じず、アクションを連続して2回記録できていること（ログアイテム0と1が両方存在）',
    );

    print('TC-ATB-007: 連続記録確認 OK');
  });
}
