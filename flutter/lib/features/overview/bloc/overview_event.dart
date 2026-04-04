import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/transaction/event/event_domain.dart';

sealed class OverviewEvent extends Equatable {
  const OverviewEvent();
}

/// Overview画面の表示時
class OverviewStarted extends OverviewEvent {
  final EventDomain event;
  final TopicConfig topicConfig;

  const OverviewStarted({required this.event, required this.topicConfig});

  @override
  List<Object?> get props => [event, topicConfig];
}

/// EventDetailBlocからTopicが変更されたとき
class OverviewTopicConfigUpdated extends OverviewEvent {
  final TopicConfig config;
  final EventDomain event;

  const OverviewTopicConfigUpdated({required this.config, required this.event});

  @override
  List<Object?> get props => [config, event];
}
