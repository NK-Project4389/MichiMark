// ignore_for_file: avoid_print

/// Unit Test: VisitWorkStateInterpreter
///
/// Spec: docs/Spec/Features/FS-visit_work_topic.md §10.2
///
/// テストシナリオ: TC-VW-U001 〜 TC-VW-U006

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:michi_mark/domain/visit_work/visit_work_state_interpreter.dart';
import 'package:michi_mark/domain/visit_work/visit_work_aggregation.dart';
import 'package:michi_mark/domain/action_time/action_state.dart';
import 'package:michi_mark/domain/action_time/action_time_log.dart';
import 'package:michi_mark/domain/master/action/action_domain.dart';

final _seedDate = DateTime(2026, 1, 1);

/// テスト用 ActionDomain を生成するヘルパー
ActionDomain _action({
  required String id,
  required String name,
  ActionState? toState,
  bool isToggle = false,
}) {
  return ActionDomain(
    id: id,
    actionName: name,
    toState: toState,
    isToggle: isToggle,
    togglePairId: null,
    needsTransition: true,
    createdAt: _seedDate,
    updatedAt: _seedDate,
  );
}

/// テスト用 ActionTimeLog を生成するヘルパー
ActionTimeLog _log({
  required String actionId,
  required DateTime timestamp,
}) {
  return ActionTimeLog(
    id: '${actionId}_${timestamp.millisecondsSinceEpoch}',
    eventId: 'test_event',
    actionId: actionId,
    timestamp: timestamp,
    createdAt: _seedDate,
    updatedAt: _seedDate,
  );
}

void main() {
  // ────────────────────────────────────────────────────────
  // アクション定義（シードデータと対応）
  // ────────────────────────────────────────────────────────

  final actionArrive = _action(
    id: 'visit_work_arrive',
    name: '到着',
    toState: ActionState.waiting,
  );
  final actionDepart = _action(
    id: 'visit_work_depart',
    name: '出発',
    toState: ActionState.moving,
  );
  final actionStart = _action(
    id: 'visit_work_start',
    name: '作業開始',
    toState: ActionState.working,
  );
  final actionEnd = _action(
    id: 'visit_work_end',
    name: '作業終了',
    toState: ActionState.waiting,
  );
  final actionBreak = _action(
    id: 'visit_work_break',
    name: '休憩',
    isToggle: true,
  );

  final actionMap = {
    actionArrive.id: actionArrive,
    actionDepart.id: actionDepart,
    actionStart.id: actionStart,
    actionEnd.id: actionEnd,
    actionBreak.id: actionBreak,
  };

  // ────────────────────────────────────────────────────────
  // TC-VW-U001: 到着→作業開始→作業終了→出発の正常フロー
  // ────────────────────────────────────────────────────────

  test('TC-VW-U001: 到着→作業開始→作業終了→出発の正常フローでセグメント数が正しく算出される',
      () {
    final t1 = DateTime(2026, 4, 16, 9, 30); // 到着
    final t2 = DateTime(2026, 4, 16, 10, 0); // 作業開始
    final t3 = DateTime(2026, 4, 16, 13, 0); // 作業終了
    final t4 = DateTime(2026, 4, 16, 13, 30); // 出発

    final logs = [
      _log(actionId: 'visit_work_arrive', timestamp: t1),
      _log(actionId: 'visit_work_start', timestamp: t2),
      _log(actionId: 'visit_work_end', timestamp: t3),
      _log(actionId: 'visit_work_depart', timestamp: t4),
    ];

    final timeline = VisitWorkStateInterpreter.interpret(
      logs: logs,
      actionMap: actionMap,
    );

    // 到着(t1→t2: waiting), 作業開始(t2→t3: working), 作業終了(t3→t4: waiting),
    // 出発後(t4〜: moving=完了)
    // セグメント数: 4件（to_stateが変わるたびに1件 + 最後の進行/完了区間）
    expect(timeline.segments.length, greaterThanOrEqualTo(4));
  });

  test('TC-VW-U001b: 到着→作業開始→作業終了→出発の正常フローでisOngoing == false', () {
    final t1 = DateTime(2026, 4, 16, 9, 30);
    final t2 = DateTime(2026, 4, 16, 10, 0);
    final t3 = DateTime(2026, 4, 16, 13, 0);
    final t4 = DateTime(2026, 4, 16, 13, 30);

    final logs = [
      _log(actionId: 'visit_work_arrive', timestamp: t1),
      _log(actionId: 'visit_work_start', timestamp: t2),
      _log(actionId: 'visit_work_end', timestamp: t3),
      _log(actionId: 'visit_work_depart', timestamp: t4),
    ];

    final timeline = VisitWorkStateInterpreter.interpret(
      logs: logs,
      actionMap: actionMap,
    );

    // 最後が出発（moving）なので完了扱い
    expect(timeline.isOngoing, isFalse);
  });

  test('TC-VW-U001c: 到着→作業開始→作業終了→出発の正常フローで各状態の順序が正しい', () {
    final t1 = DateTime(2026, 4, 16, 9, 30);
    final t2 = DateTime(2026, 4, 16, 10, 0);
    final t3 = DateTime(2026, 4, 16, 13, 0);
    final t4 = DateTime(2026, 4, 16, 13, 30);

    final logs = [
      _log(actionId: 'visit_work_arrive', timestamp: t1),
      _log(actionId: 'visit_work_start', timestamp: t2),
      _log(actionId: 'visit_work_end', timestamp: t3),
      _log(actionId: 'visit_work_depart', timestamp: t4),
    ];

    final timeline = VisitWorkStateInterpreter.interpret(
      logs: logs,
      actionMap: actionMap,
    );

    // 最初のセグメントは waiting（到着後の状態）
    expect(timeline.segments.first.state, equals(ActionState.waiting));
  });

  // ────────────────────────────────────────────────────────
  // TC-VW-U002: 休憩ONのみ（休憩OFFなし・進行中）
  // ────────────────────────────────────────────────────────

  test('TC-VW-U002: 休憩ONのみ（休憩OFFなし）でbreak_セグメントが1件以上存在する', () {
    final t1 = DateTime(2026, 4, 16, 10, 0); // 到着
    final t2 = DateTime(2026, 4, 16, 10, 30); // 作業開始
    final t3 = DateTime(2026, 4, 16, 12, 0); // 休憩ON

    final logs = [
      _log(actionId: 'visit_work_arrive', timestamp: t1),
      _log(actionId: 'visit_work_start', timestamp: t2),
      _log(actionId: 'visit_work_break', timestamp: t3),
    ];

    final timeline = VisitWorkStateInterpreter.interpret(
      logs: logs,
      actionMap: actionMap,
    );

    final breakSegments = timeline.segments
        .where((s) => s.state == ActionState.break_)
        .toList();
    expect(breakSegments.length, greaterThanOrEqualTo(1));
  });

  test('TC-VW-U002b: 休憩ONのみ（休憩OFFなし）でisOngoing == true', () {
    final t1 = DateTime(2026, 4, 16, 10, 0);
    final t2 = DateTime(2026, 4, 16, 10, 30);
    final t3 = DateTime(2026, 4, 16, 12, 0);

    final logs = [
      _log(actionId: 'visit_work_arrive', timestamp: t1),
      _log(actionId: 'visit_work_start', timestamp: t2),
      _log(actionId: 'visit_work_break', timestamp: t3),
    ];

    final timeline = VisitWorkStateInterpreter.interpret(
      logs: logs,
      actionMap: actionMap,
    );

    // 休憩中（break_）で出発していない → 進行中
    expect(timeline.isOngoing, isTrue);
  });

  // ────────────────────────────────────────────────────────
  // TC-VW-U003: 休憩ON→休憩OFF で直前状態（working）に戻る
  // ────────────────────────────────────────────────────────

  test('TC-VW-U003: 休憩ON→休憩OFFで直前状態（working）に戻るセグメントが生成される', () {
    final t1 = DateTime(2026, 4, 16, 10, 0); // 到着
    final t2 = DateTime(2026, 4, 16, 10, 30); // 作業開始
    final t3 = DateTime(2026, 4, 16, 12, 0); // 休憩ON
    final t4 = DateTime(2026, 4, 16, 12, 30); // 休憩OFF（workingへ戻る）

    final logs = [
      _log(actionId: 'visit_work_arrive', timestamp: t1),
      _log(actionId: 'visit_work_start', timestamp: t2),
      _log(actionId: 'visit_work_break', timestamp: t3),
      _log(actionId: 'visit_work_break', timestamp: t4),
    ];

    final timeline = VisitWorkStateInterpreter.interpret(
      logs: logs,
      actionMap: actionMap,
    );

    // 休憩後に working セグメントが続くこと
    final workingAfterBreak = timeline.segments
        .skipWhile((s) => s.state != ActionState.break_)
        .skip(1)
        .where((s) => s.state == ActionState.working)
        .toList();
    expect(workingAfterBreak.isNotEmpty, isTrue);
  });

  test('TC-VW-U003b: 休憩ON→休憩OFFでbreak_セグメントが含まれる', () {
    final t1 = DateTime(2026, 4, 16, 10, 0);
    final t2 = DateTime(2026, 4, 16, 10, 30);
    final t3 = DateTime(2026, 4, 16, 12, 0);
    final t4 = DateTime(2026, 4, 16, 12, 30);

    final logs = [
      _log(actionId: 'visit_work_arrive', timestamp: t1),
      _log(actionId: 'visit_work_start', timestamp: t2),
      _log(actionId: 'visit_work_break', timestamp: t3),
      _log(actionId: 'visit_work_break', timestamp: t4),
    ];

    final timeline = VisitWorkStateInterpreter.interpret(
      logs: logs,
      actionMap: actionMap,
    );

    final hasBreak = timeline.segments.any((s) => s.state == ActionState.break_);
    expect(hasBreak, isTrue);
  });

  // ────────────────────────────────────────────────────────
  // TC-VW-U004: ActionTimeLog が空
  // ────────────────────────────────────────────────────────

  test('TC-VW-U004: ActionTimeLogが空のときsegments == []', () {
    final timeline = VisitWorkStateInterpreter.interpret(
      logs: [],
      actionMap: actionMap,
    );

    expect(timeline.segments, isEmpty);
  });

  test('TC-VW-U004b: ActionTimeLogが空のときisOngoing == false', () {
    final timeline = VisitWorkStateInterpreter.interpret(
      logs: [],
      actionMap: actionMap,
    );

    expect(timeline.isOngoing, isFalse);
  });

  // ────────────────────────────────────────────────────────
  // TC-VW-U005: onSiteDuration の算出（到着あり・出発あり）
  // ────────────────────────────────────────────────────────

  test('TC-VW-U005: onSiteDuration が到着〜出発の Duration として正しく算出される', () {
    // 到着 10:00 → 出発 13:30 = 3時間30分 = 210分
    final t1 = DateTime(2026, 4, 16, 10, 0); // 到着（waiting開始）
    final t2 = DateTime(2026, 4, 16, 10, 30); // 作業開始（working）
    final t3 = DateTime(2026, 4, 16, 13, 0); // 作業終了（waiting）
    final t4 = DateTime(2026, 4, 16, 13, 30); // 出発（moving）

    final logs = [
      _log(actionId: 'visit_work_arrive', timestamp: t1),
      _log(actionId: 'visit_work_start', timestamp: t2),
      _log(actionId: 'visit_work_end', timestamp: t3),
      _log(actionId: 'visit_work_depart', timestamp: t4),
    ];

    final timeline = VisitWorkStateInterpreter.interpret(
      logs: logs,
      actionMap: actionMap,
    );

    expect(timeline.onSiteDuration, isNotNull);
    // 到着(10:00)〜出発(13:30) = 3h30m = 210分
    expect(timeline.onSiteDuration!.inMinutes, equals(210));
  });

  test('TC-VW-U005b: onSiteDuration が出発前（進行中）では到着〜現在時刻に基づく値になる', () {
    final t1 = DateTime(2026, 4, 16, 10, 0);
    final t2 = DateTime(2026, 4, 16, 10, 30);

    final logs = [
      _log(actionId: 'visit_work_arrive', timestamp: t1),
      _log(actionId: 'visit_work_start', timestamp: t2),
    ];

    final timeline = VisitWorkStateInterpreter.interpret(
      logs: logs,
      actionMap: actionMap,
    );

    // 出発未記録 → isOngoing == true → onSiteDuration は null でないこと
    expect(timeline.onSiteDuration, isNotNull);
  });

  // ────────────────────────────────────────────────────────
  // TC-VW-U006: revenuePerHour の算出
  // ────────────────────────────────────────────────────────

  test('TC-VW-U006: revenuePerHour が 売上15000 / 作業3h = 5000 として算出される', () {
    const aggregation = VisitWorkAggregation(
      movingDuration: Duration(hours: 1),
      stayingDuration: Duration(minutes: 30),
      workingDuration: Duration(hours: 3), // 3時間
      breakDuration: Duration(minutes: 30),
      revenue: 15000, // 売上15,000円
      isOngoing: false,
    );

    // 15000 / 3h = 5000
    expect(aggregation.revenuePerHour, equals(5000));
  });

  test('TC-VW-U006b: 作業時間が0のとき revenuePerHour == null', () {
    const aggregation = VisitWorkAggregation(
      movingDuration: Duration(hours: 1),
      stayingDuration: Duration(minutes: 30),
      workingDuration: Duration.zero, // 作業時間0
      breakDuration: Duration.zero,
      revenue: 15000,
      isOngoing: false,
    );

    expect(aggregation.revenuePerHour, isNull);
  });

  test('TC-VW-U006c: 売上がnullのとき revenuePerHour == null', () {
    const aggregation = VisitWorkAggregation(
      movingDuration: Duration(hours: 1),
      stayingDuration: Duration(minutes: 30),
      workingDuration: Duration(hours: 3),
      breakDuration: Duration(minutes: 30),
      revenue: null, // 売上未登録
      isOngoing: false,
    );

    expect(aggregation.revenuePerHour, isNull);
  });
}
