import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_domain.dart';
import '../projection/event_list_projection.dart';

/// EventListのDelegate（画面遷移・操作意図の通知）
sealed class EventListDelegate extends Equatable {
  const EventListDelegate();
}

/// イベント詳細画面へ遷移する
class OpenEventDetailDelegate extends EventListDelegate {
  final String eventId;
  const OpenEventDetailDelegate(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// Topic選択済みでイベント追加画面へ遷移する
class OpenAddEventWithTopicDelegate extends EventListDelegate {
  final TopicType topicType;
  final String eventId;
  const OpenAddEventWithTopicDelegate({
    required this.topicType,
    required this.eventId,
  });

  @override
  List<Object?> get props => [topicType, eventId];
}

/// 設定画面へ遷移する
class OpenSettingsDelegate extends EventListDelegate {
  const OpenSettingsDelegate();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------

sealed class EventListState extends Equatable {
  const EventListState();
}

/// 初期状態・ローディング中
class EventListLoading extends EventListState {
  const EventListLoading();

  @override
  List<Object?> get props => [];
}

/// 一覧表示中
class EventListLoaded extends EventListState {
  final EventListProjection projection;
  final EventListDelegate? delegate;

  /// BottomSheet表示トリガー。trueになったらPageがBottomSheetを表示する
  final bool showTopicSelection;

  const EventListLoaded({
    required this.projection,
    this.delegate,
    this.showTopicSelection = false,
  });

  EventListLoaded copyWith({
    EventListProjection? projection,
    EventListDelegate? delegate,
    bool? showTopicSelection,
  }) {
    return EventListLoaded(
      projection: projection ?? this.projection,
      delegate: delegate,
      showTopicSelection: showTopicSelection ?? false,
    );
  }

  @override
  List<Object?> get props => [projection, delegate, showTopicSelection];
}

/// エラー発生
class EventListError extends EventListState {
  final String message;
  const EventListError({required this.message});

  @override
  List<Object?> get props => [message];
}
