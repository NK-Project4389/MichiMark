import '../../domain/master/member/member_domain.dart';
import '../../domain/topic/topic_config.dart';

/// go_router の extra 経由で LinkDetailPage に渡す引数
class LinkDetailArgs {
  final String eventId;
  final TopicConfig topicConfig;

  /// メンバー選択候補（基本情報のメンバーのみを表示するために使用）
  final List<MemberDomain> eventMembers;

  const LinkDetailArgs({
    required this.eventId,
    required this.topicConfig,
    this.eventMembers = const [],
  });
}
