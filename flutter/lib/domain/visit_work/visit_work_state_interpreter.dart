import '../action_time/action_state.dart';
import '../action_time/action_time_log.dart';
import '../master/action/action_domain.dart';
import 'visit_work_segment.dart';
import 'visit_work_timeline.dart';

/// ActionTimeLog のリストを VisitWorkTimeline に変換する純粋な Domain Service。
/// 外部依存なし・DB 操作なし。
class VisitWorkStateInterpreter {
  VisitWorkStateInterpreter._();

  /// logs（時系列昇順）と actionMap を受け取り VisitWorkTimeline を返す。
  static VisitWorkTimeline interpret({
    required List<ActionTimeLog> logs,
    required Map<String, ActionDomain> actionMap,
  }) {
    if (logs.isEmpty) {
      return const VisitWorkTimeline(segments: [], isOngoing: false);
    }

    // 1. timestamp 昇順にソート
    final sorted = [...logs]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // 2. 初期化
    ActionState? currentState;
    ActionState? preBreakState;
    DateTime? prevTimestamp;
    final segments = <VisitWorkSegment>[];

    for (final log in sorted) {
      final action = actionMap[log.actionId];
      if (action == null) continue; // 削除済み ActionDomain への参照はスキップ

      final ActionState nextState;

      if (action.isToggle) {
        // 休憩トグル
        if (currentState == ActionState.break_) {
          // 休憩 OFF: 直前の状態に戻る
          nextState = preBreakState ?? ActionState.waiting;
          preBreakState = null;
        } else {
          // 休憩 ON: 現在状態を記憶してbreak へ
          preBreakState = currentState ?? ActionState.waiting;
          nextState = ActionState.break_;
        }
      } else {
        // 通常アクション
        final toState = action.toState;
        nextState = toState ?? (currentState ?? ActionState.waiting);
      }

      final prev = prevTimestamp;
      final cur = currentState;
      if (cur != null && prev != null) {
        segments.add(VisitWorkSegment(
          state: cur,
          from: prev,
          to: log.timestamp,
        ));
      }

      currentState = nextState;
      prevTimestamp = log.timestamp;
    }

    // 5. 最後のセグメント（進行中区間）を追加
    final cur = currentState;
    final prev = prevTimestamp;
    if (cur != null && prev != null) {
      // 最後が moving かつセグメントが存在する場合は完了とみなす
      final isOngoing = !(cur == ActionState.moving && segments.isNotEmpty);
      final toTime = isOngoing ? DateTime.now() : prev;
      segments.add(VisitWorkSegment(
        state: cur,
        from: prev,
        to: toTime,
      ));
      return VisitWorkTimeline(segments: segments, isOngoing: isOngoing);
    }

    return const VisitWorkTimeline(segments: [], isOngoing: false);
  }
}
