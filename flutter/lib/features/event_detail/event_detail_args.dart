import '../../domain/topic/topic_domain.dart';

/// EventDetailページへの遷移引数。
/// 新規作成時に initialTopicType を指定する。既存イベントでは null を渡す。
class EventDetailArgs {
  final TopicType? initialTopicType;

  const EventDetailArgs({this.initialTopicType});
}
