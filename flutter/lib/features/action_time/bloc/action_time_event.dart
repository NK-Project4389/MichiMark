import 'package:equatable/equatable.dart';

sealed class ActionTimeEvent extends Equatable {
  const ActionTimeEvent();
}

/// 画面表示時: 指定EventのActionTimeLogをRepositoryから読み込む
class ActionTimeStarted extends ActionTimeEvent {
  final String eventId;
  const ActionTimeStarted(this.eventId);

  @override
  List<Object?> get props => [eventId];
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
