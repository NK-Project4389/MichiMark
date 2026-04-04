import '../../domain/topic/topic_config.dart';

/// go_router の extra 経由で MarkDetailPage に渡す引数
class MarkDetailArgs {
  final String eventId;
  final TopicConfig topicConfig;

  const MarkDetailArgs({
    required this.eventId,
    required this.topicConfig,
  });
}
