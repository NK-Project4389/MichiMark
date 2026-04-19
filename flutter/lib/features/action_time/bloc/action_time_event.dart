import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';

sealed class ActionTimeEvent extends Equatable {
  const ActionTimeEvent();
}

/// 画面表示時: 指定EventのActionTimeLogをRepositoryから読み込む（REQ-002）
class ActionTimeStarted extends ActionTimeEvent {
  final String eventId;
  final TopicConfig topicConfig;
  final MarkOrLink markOrLink;

  /// 操作対象のMarkLinkID（F-10: visitWorkトピックで使用）
  final String? markLinkId;

  const ActionTimeStarted(
    this.eventId, {
    required this.topicConfig,
    this.markOrLink = MarkOrLink.mark,
    this.markLinkId,
  });

  @override
  List<Object?> get props => [eventId, topicConfig, markOrLink, markLinkId];
}

/// ActionボタンタップTime: 選択したActionのActionTimeLogを現在時刻で記録する
class ActionTimeLogRecorded extends ActionTimeEvent {
  final String actionId;
  const ActionTimeLogRecorded(this.actionId);

  @override
  List<Object?> get props => [actionId];
}

/// 休憩トグルボタンタップ: 現在状態に応じて休憩開始または休憩終了のActionTimeLogを記録する
class ActionTimeBreakToggled extends ActionTimeEvent {
  const ActionTimeBreakToggled();

  @override
  List<Object?> get props => [];
}

/// ログ削除操作: 指定ActionTimeLogを論理削除する
class ActionTimeLogDeleted extends ActionTimeEvent {
  final String logId;
  const ActionTimeLogDeleted(this.logId);

  @override
  List<Object?> get props => [logId];
}

/// 時刻変更操作: 指定ActionTimeLogのadjustedAtを更新する
class ActionTimeLogAdjustedAtUpdated extends ActionTimeEvent {
  final String logId;
  final DateTime adjustedAt;
  const ActionTimeLogAdjustedAtUpdated(this.logId, this.adjustedAt);

  @override
  List<Object?> get props => [logId, adjustedAt];
}
