import '../../domain/master/action/action_domain.dart';
import '../../domain/master/member/member_domain.dart';
import '../../domain/master/tag/tag_domain.dart';
import '../../domain/master/trans/trans_domain.dart';
import '../../domain/topic/topic_domain.dart';

/// 選択画面から context.pop() で返す結果型
sealed class SelectionResult {
  const SelectionResult();
}

/// 交通手段の選択結果（単一選択。null = 未選択）
class TransSelectionResult extends SelectionResult {
  final TransDomain? selected;
  const TransSelectionResult(this.selected);
}

/// メンバーの選択結果（複数選択）
class MembersSelectionResult extends SelectionResult {
  final List<MemberDomain> selected;
  const MembersSelectionResult(this.selected);
}

/// タグの選択結果（複数選択）
class TagsSelectionResult extends SelectionResult {
  final List<TagDomain> selected;
  const TagsSelectionResult(this.selected);
}

/// アクションの選択結果（複数選択）
class ActionsSelectionResult extends SelectionResult {
  final List<ActionDomain> selected;
  const ActionsSelectionResult(this.selected);
}

/// トピックの選択結果（単一選択。null = 未選択）
class TopicSelectionResult extends SelectionResult {
  final TopicDomain? selected;
  const TopicSelectionResult(this.selected);
}
