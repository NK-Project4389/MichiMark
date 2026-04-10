import '../../domain/master/member/member_domain.dart';
import '../../domain/topic/topic_config.dart';

/// go_router の extra 経由で LinkDetailPage に渡す引数
class LinkDetailArgs {
  final String eventId;
  final TopicConfig topicConfig;

  /// メンバー選択候補（基本情報のメンバーのみを表示するために使用）
  final List<MemberDomain> eventMembers;

  /// null = 末尾追加（現行動作）、non-null = 指定位置に挿入
  final int? insertAfterSeq;

  const LinkDetailArgs({
    required this.eventId,
    required this.topicConfig,
    this.eventMembers = const [],
    this.insertAfterSeq,
  });
}
