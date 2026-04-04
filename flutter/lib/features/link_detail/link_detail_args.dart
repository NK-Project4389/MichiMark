import '../../domain/topic/topic_config.dart';

/// go_router の extra 経由で LinkDetailPage に渡す引数
class LinkDetailArgs {
  final String eventId;
  final TopicConfig topicConfig;

  const LinkDetailArgs({
    required this.eventId,
    required this.topicConfig,
  });
}
