import '../../domain/master/member/member_domain.dart';
import '../../domain/topic/topic_config.dart';

/// go_router の extra 経由で MarkDetailPage に渡す引数
class MarkDetailArgs {
  final String eventId;
  final TopicConfig topicConfig;

  /// メーター入力の初期値（新規追加時のみ使用。空文字はデフォルト）
  final String initialMeterValueInput;

  /// メンバーの初期値（前の地点から引き継ぎ。新規追加時のみ使用）
  final List<MemberDomain> initialSelectedMembers;

  /// 日付の初期値（前の地点から引き継ぎ。null の場合は Bloc 側で DateTime.now() を使用）
  final DateTime? initialMarkLinkDate;

  /// メンバー選択候補（イベントメンバー一覧）
  final List<MemberDomain> eventMembers;

  /// null = 末尾追加（現行動作）、non-null = 指定位置に挿入
  final int? insertAfterSeq;

  const MarkDetailArgs({
    required this.eventId,
    required this.topicConfig,
    this.initialMeterValueInput = '',
    this.initialSelectedMembers = const [],
    this.initialMarkLinkDate,
    this.eventMembers = const [],
    this.insertAfterSeq,
  });
}
