import 'package:intl/intl.dart';
import '../domain/action_time/action_state.dart';
import '../domain/action_time/action_time_log.dart';
import '../domain/master/action/action_domain.dart';
import '../domain/topic/topic_config.dart';
import '../domain/transaction/mark_link/mark_or_link.dart';
import '../features/action_time/draft/action_time_draft.dart';
import '../features/action_time/projection/action_time_projection.dart';

/// ActionTimeの状態導出ロジックを担当するAdapter。
/// Widget・BLoCに状態導出ロジックを書かない。
class ActionTimeAdapter {
  ActionTimeAdapter._();

  static final _timeFormat = DateFormat('HH:mm');

  /// ログリストから現在のActionStateを導出する。
  /// REQ-005: needsTransition == true のログのみ toState 計算の対象とする。
  /// ログが空（またはフィルタ後が空）の場合は waiting をデフォルト値とする。
  static ActionState deriveCurrentState(
    List<ActionTimeLog> logs,
    Map<String, ActionDomain> actionMap,
  ) {
    if (logs.isEmpty) return ActionState.waiting;
    // needsTransition == true のログのみで状態遷移を計算する（REQ-005）
    final transitionLogs = logs.where((log) {
      final action = actionMap[log.actionId];
      return action?.needsTransition ?? true;
    }).toList();
    if (transitionLogs.isEmpty) return ActionState.waiting;
    final lastLog = transitionLogs.last;
    final action = actionMap[lastLog.actionId];
    return action?.toState ?? ActionState.waiting;
  }

  /// TopicConfigのmarkActionsまたはlinkActionsからAction候補を導出する（REQ-002）。
  /// fromState照合ロジックは廃止（REQ-004）。
  static List<ActionDomain> deriveAvailableActions(
    MarkOrLink markOrLink,
    TopicConfig topicConfig,
    Map<String, ActionDomain> actionMap,
  ) {
    final actionIds = markOrLink == MarkOrLink.mark
        ? topicConfig.markActions
        : topicConfig.linkActions;

    return actionIds
        .map((id) => actionMap[id])
        .where((action) {
          if (action == null) return false;
          if (action.isDeleted || !action.isVisible) return false;
          return true;
        })
        .cast<ActionDomain>()
        .toList();
  }

  /// Draft・Projectionを生成する（REQ-002・004・005対応）。
  static (ActionTimeDraft, ActionTimeProjection) buildDraftAndProjection({
    required String eventId,
    required List<ActionTimeLog> logs,
    required List<ActionDomain> allActions,
    required TopicConfig topicConfig,
    required MarkOrLink markOrLink,
    String? markLinkId,
  }) {
    final actionMap = {for (final a in allActions) a.id: a};
    final sortedLogs = List.of(logs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final currentState = deriveCurrentState(sortedLogs, actionMap);
    final availableActions = deriveAvailableActions(markOrLink, topicConfig, actionMap);

    final draft = ActionTimeDraft(
      eventId: eventId,
      currentState: currentState,
      availableActions: availableActions,
      logs: sortedLogs,
      topicConfig: topicConfig,
      markOrLink: markOrLink,
      markLinkId: markLinkId,
    );

    final logItems = sortedLogs.map((log) {
      final action = actionMap[log.actionId];
      final toLabel = action?.toState?.label ?? '変化なし';
      // REQ-004: fromState は廃止。状態遷移ラベルは toState のみで表示
      final transitionLabel = '→ $toLabel';
      return ActionTimeLogProjection(
        id: log.id,
        actionName: action?.actionName ?? '（不明）',
        timestampLabel: _timeFormat.format(log.timestamp),
        transitionLabel: transitionLabel,
      );
    }).toList();

    final isBreakActive = currentState == ActionState.break_;

    // buttonItems: availableActionsの順に各アクションの最新タイムスタンプを逆引きして生成
    // logs全体のうち最大timestampのlogのactionIdをlastPressedActionIdとする
    final lastPressedActionId = sortedLogs.isNotEmpty ? sortedLogs.last.actionId : null;

    // アクションIDごとに最新タイムスタンプを算出
    final Map<String, DateTime> lastLoggedAtMap = {};
    for (final log in sortedLogs) {
      final existing = lastLoggedAtMap[log.actionId];
      if (existing == null || log.timestamp.isAfter(existing)) {
        lastLoggedAtMap[log.actionId] = log.timestamp;
      }
    }

    final buttonItems = availableActions.map((action) {
      final lastLoggedAt = lastLoggedAtMap[action.id];
      final lastLoggedTimeLabel =
          lastLoggedAt != null ? _timeFormat.format(lastLoggedAt) : null;
      return ActionButtonProjection(
        actionId: action.id,
        actionName: action.actionName,
        lastLoggedTimeLabel: lastLoggedTimeLabel,
        isLastPressed: action.id == lastPressedActionId,
      );
    }).toList();

    final projection = ActionTimeProjection(
      currentStateLabel: currentState.label,
      logItems: logItems,
      isBreakActive: isBreakActive,
      buttonItems: buttonItems,
    );

    return (draft, projection);
  }
}
