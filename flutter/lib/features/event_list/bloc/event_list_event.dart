import 'package:equatable/equatable.dart';

sealed class EventListEvent extends Equatable {
  const EventListEvent();
}

/// 画面が表示されたとき
class EventListStarted extends EventListEvent {
  const EventListStarted();

  @override
  List<Object?> get props => [];
}

/// イベント行がタップされたとき
class EventListItemTapped extends EventListEvent {
  final String eventId;
  const EventListItemTapped(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// 追加ボタンが押されたとき
class EventListAddButtonPressed extends EventListEvent {
  const EventListAddButtonPressed();

  @override
  List<Object?> get props => [];
}

/// 設定ボタンが押されたとき
class EventListSettingsButtonPressed extends EventListEvent {
  const EventListSettingsButtonPressed();

  @override
  List<Object?> get props => [];
}

/// イベントの削除が要求されたとき
class EventListDeleteRequested extends EventListEvent {
  final String eventId;
  const EventListDeleteRequested(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
