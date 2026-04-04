import 'package:equatable/equatable.dart';
import '../../../domain/action_time/action_state.dart';
import '../../../domain/action_time/action_time_log.dart';
import '../../../domain/master/action/action_domain.dart';

/// ActionTimeDraft。永続化しない。
class ActionTimeDraft extends Equatable {
  /// 対象イベントID
  final String eventId;

  /// 現在の導出状態
  final ActionState currentState;

  /// 現在状態から発火可能なAction一覧
  final List<ActionDomain> availableActions;

  /// 読み込み済みのActionTimeLog（timestamp ASC）
  final List<ActionTimeLog> logs;

  const ActionTimeDraft({
    required this.eventId,
    this.currentState = ActionState.waiting,
    this.availableActions = const [],
    this.logs = const [],
  });

  ActionTimeDraft copyWith({
    String? eventId,
    ActionState? currentState,
    List<ActionDomain>? availableActions,
    List<ActionTimeLog>? logs,
  }) {
    return ActionTimeDraft(
      eventId: eventId ?? this.eventId,
      currentState: currentState ?? this.currentState,
      availableActions: availableActions ?? this.availableActions,
      logs: logs ?? this.logs,
    );
  }

  @override
  List<Object?> get props => [eventId, currentState, availableActions, logs];
}
