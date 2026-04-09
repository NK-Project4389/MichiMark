import 'package:equatable/equatable.dart';
import '../../../domain/action_time/action_state.dart';
import '../../../domain/action_time/action_time_log.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';

/// ActionTimeDraft。永続化しない。
class ActionTimeDraft extends Equatable {
  /// 対象イベントID
  final String eventId;

  /// 現在の導出状態
  final ActionState currentState;

  /// TopicConfigのアクションリストから提示する候補（REQ-002）
  final List<ActionDomain> availableActions;

  /// 読み込み済みのActionTimeLog（timestamp ASC）
  final List<ActionTimeLog> logs;

  /// アクション候補提示に使用するTopicConfig（REQ-002）
  final TopicConfig topicConfig;

  /// 現在操作対象がMarkかLinkか（REQ-002）
  final MarkOrLink markOrLink;

  const ActionTimeDraft({
    required this.eventId,
    this.currentState = ActionState.waiting,
    this.availableActions = const [],
    this.logs = const [],
    TopicConfig? topicConfig,
    this.markOrLink = MarkOrLink.mark,
  }) : topicConfig = topicConfig ??
            const TopicConfig(
              showMeterValue: true,
              showFuelDetail: true,
              addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
              showLinkDistance: true,
              showKmPerGas: true,
              showPricePerGas: true,
              showPayMember: true,
              showPaymentInfoTab: true,
            );

  ActionTimeDraft copyWith({
    String? eventId,
    ActionState? currentState,
    List<ActionDomain>? availableActions,
    List<ActionTimeLog>? logs,
    TopicConfig? topicConfig,
    MarkOrLink? markOrLink,
  }) {
    return ActionTimeDraft(
      eventId: eventId ?? this.eventId,
      currentState: currentState ?? this.currentState,
      availableActions: availableActions ?? this.availableActions,
      logs: logs ?? this.logs,
      topicConfig: topicConfig ?? this.topicConfig,
      markOrLink: markOrLink ?? this.markOrLink,
    );
  }

  @override
  List<Object?> get props => [eventId, currentState, availableActions, logs, topicConfig, markOrLink];
}
