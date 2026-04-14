import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_domain.dart';

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

/// BottomSheetでTopicTypeが選択されたとき
class EventListTopicSelectedForNewEvent extends EventListEvent {
  final TopicType topicType;
  final String eventId;
  const EventListTopicSelectedForNewEvent({
    required this.topicType,
    required this.eventId,
  });

  @override
  List<Object?> get props => [topicType, eventId];
}

/// delegate を消費してクリアするとき（画面遷移完了後に dispatch）
class EventListDelegateConsumed extends EventListEvent {
  const EventListDelegateConsumed();

  @override
  List<Object?> get props => [];
}

/// トピック選択シートがキャンセルされたとき（showTopicSelectionをリセット）
class EventListTopicSelectionDismissed extends EventListEvent {
  const EventListTopicSelectionDismissed();

  @override
  List<Object?> get props => [];
}
