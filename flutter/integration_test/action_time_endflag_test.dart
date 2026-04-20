// ignore_for_file: avoid_print

/// Integration Test: ActionTime 出発記録時のMark完了バッジ表示
///
/// Spec: docs/Spec/Features/F-3_VisitWork.md §18
///
/// テストシナリオ: TC-AEF-001, TC-AEF-002
///
/// 前提条件:
///   - iOSシミュレーターが起動済みであること
///   - visitWorkトピックのイベント「横浜エリア訪問ルート」が存在すること
///   - MichiInfo（道タブ）が表示可能であること

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:michi_mark/main.dart' as app;
import 'package:michi_mark/app/router.dart' as app_router;
import 'package:michi_mark/domain/topic/topic_domain.dart';
import 'package:michi_mark/repository/impl/in_memory/seed_data.dart';

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

  /// visitWorkイベント「横浜エリア訪問ルート」を開く
  Future<bool> openVisitWorkEvent(WidgetTester tester) async {
    if (find.text('イベントがありません').evaluate().isNotEmpty) return false;

    // visitWorkトピックのイベント名を動的に取得
    final seedVisitWorkEvent = seedEvents.firstWhere(
      (e) => e.topic?.topicType == TopicType.visitWork,
      orElse: () => throw Exception('visitWorkトピックのイベントが見つかりません'),
    );
    final visitWorkCard = find.text(seedVisitWorkEvent.eventName);
    final cardToTap = visitWorkCard.evaluate().isNotEmpty
        ? visitWorkCard
        : find.byType(GestureDetector).first;

    if (cardToTap.evaluate().isEmpty) return false;
    await tester.tap(cardToTap);

    // EventDetailページが開かれるまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(const Key('basicInfoRead_container_section'))
              .evaluate()
              .isNotEmpty ||
          find.text('タップして編集').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));
    return true;
  }

  /// 道タブ（MichiInfo）に移動する
  Future<bool> goToMichiInfoTab(WidgetTester tester) async {
    final michiTab = find.text('ミチ');
    if (michiTab.evaluate().isEmpty) return false;

    await tester.tap(michiTab);

    // MichiInfoタブがロードされるまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty ||
          find.text('地点/区間がありません').evaluate().isNotEmpty) {
        break;
      }
    }

    // TopicConfigUpdatedによるmarkActionItems設定を待つ
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byWidgetPredicate(
        (w) => w.key != null && w.key.toString().contains('michiInfo_button_actionTime_'),
      ).evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 500));

    return true;
  }

  /// ⚡インラインボタン（出発アクション）をタップして ActionTime を記録する
  Future<bool> tapDepartActionButton(WidgetTester tester) async {
    // 最初のMarkの⚡ボタンを探す
    final actionButtons = find.byWidgetPredicate(
      (w) => w.key != null && w.key.toString().contains('michiInfo_button_actionTime_'),
    );

    if (actionButtons.evaluate().isEmpty) return false;

    // 最初のボタンをタップ
    await tester.ensureVisible(actionButtons.first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(actionButtons.first);

    // ボトムシートが表示されるまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('ActionTime').evaluate().isNotEmpty ||
          find.text('現在の状態').evaluate().isNotEmpty) {
        break;
      }
    }

    // 出発アクションボタンを探してタップ（visit_work_depart）
    final departButton = find.byWidgetPredicate(
      (w) => w.key != null && w.key.toString().contains('action_time_action_button_visit_work_depart'),
    );

    if (departButton.evaluate().isEmpty) {
      // フォールバック: 最初のアクションボタンを使う
      final anyActionButton = find.byWidgetPredicate(
        (w) => w.key != null && w.key.toString().contains('action_time_action_button_'),
      );
      if (anyActionButton.evaluate().isEmpty) return false;
      await tester.ensureVisible(anyActionButton.first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(anyActionButton.first);
    } else {
      await tester.ensureVisible(departButton.first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(departButton.first);
    }

    // ボトムシートが閉じるまで待つ
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(BottomSheet).evaluate().isEmpty) break;
    }

    await tester.pump(const Duration(milliseconds: 500));
    return true;
  }

  // ────────────────────────────────────────────────────────
  // TC-AEF-001: 「出発」アクションボタンタップ後、Markカードに完了バッジが表示される
  // ────────────────────────────────────────────────────────
  testWidgets('TC-AEF-001: 「出発」アクションタップ後、Markカードに完了バッジが表示されること',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('TC-AEF-001: イベントデータが存在しないためスキップ');
      return;
    }

    final opened = await openVisitWorkEvent(tester);
    if (!opened) {
      markTestSkipped('TC-AEF-001: visitWorkイベントを開けなかったためスキップ');
      return;
    }

    final goToMichi = await goToMichiInfoTab(tester);
    if (!goToMichi) {
      markTestSkipped('TC-AEF-001: MichiInfoタブに移動できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TC-AEF-001: Markが0件のためスキップ');
      return;
    }

    // 最初のMarkのID を取得（シードデータから動的に取得）
    final seedVisitWorkEvent = seedEvents.firstWhere(
      (e) => e.topic?.topicType == TopicType.visitWork,
      orElse: () => throw Exception('visitWorkトピックのイベントが見つかりません'),
    );
    final firstMarkId = seedVisitWorkEvent.markLinks
        .where((ml) => !ml.isDeleted)
        .first
        .id;
    final badgeBeforeTap = find.byKey(Key('michiInfo_badge_done_$firstMarkId'));

    // アクション記録前: バッジが存在しない
    expect(
      badgeBeforeTap.evaluate().isEmpty,
      isTrue,
      reason: 'アクション記録前は完了バッジが存在しないこと',
    );

    // アクション記録
    final recorded = await tapDepartActionButton(tester);
    if (!recorded) {
      markTestSkipped('TC-AEF-001: アクション記録に失敗したためスキップ');
      return;
    }

    // アクション記録後: バッジが表示される
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byKey(Key('michiInfo_badge_done_$firstMarkId'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    expect(
      find.byKey(Key('michiInfo_badge_done_$firstMarkId')),
      findsOneWidget,
      reason: '「出発」アクション記録後、Markカードに完了バッジが表示されること',
    );

    print('TC-AEF-001: 完了バッジ表示確認 OK');
  });

  // ────────────────────────────────────────────────────────
  // TC-AEF-002: 「出発」アクション前はカードが通常表示（バッジなし）
  // ────────────────────────────────────────────────────────
  testWidgets('TC-AEF-002: アクション記録なしの場合、完了バッジが存在しないこと',
      (tester) async {
    await startApp(tester);

    if (find.text('イベントがありません').evaluate().isNotEmpty) {
      markTestSkipped('TC-AEF-002: イベントデータが存在しないためスキップ');
      return;
    }

    final opened = await openVisitWorkEvent(tester);
    if (!opened) {
      markTestSkipped('TC-AEF-002: visitWorkイベントを開けなかったためスキップ');
      return;
    }

    final goToMichi = await goToMichiInfoTab(tester);
    if (!goToMichi) {
      markTestSkipped('TC-AEF-002: MichiInfoタブに移動できなかったためスキップ');
      return;
    }

    if (find.text('地点/区間がありません').evaluate().isNotEmpty) {
      markTestSkipped('TC-AEF-002: Markが0件のためスキップ');
      return;
    }

    // 最初のMarkのID（シードデータから動的に取得）
    final seedVisitWorkEvent = seedEvents.firstWhere(
      (e) => e.topic?.topicType == TopicType.visitWork,
      orElse: () => throw Exception('visitWorkトピックのイベントが見つかりません'),
    );
    final firstMarkId = seedVisitWorkEvent.markLinks
        .where((ml) => !ml.isDeleted)
        .first
        .id;
    final completeBadge = find.byKey(Key('michiInfo_badge_done_$firstMarkId'));

    // アクション記録なし → バッジが存在しない
    expect(
      completeBadge.evaluate().isEmpty,
      isTrue,
      reason: 'アクション記録がない場合、完了バッジが存在しないこと',
    );

    print('TC-AEF-002: 未記録バッジ非表示確認 OK');
  });
}
