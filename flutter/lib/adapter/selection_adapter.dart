import '../domain/master/action/action_domain.dart';
import '../domain/master/member/member_domain.dart';
import '../domain/master/tag/tag_domain.dart';
import '../domain/master/trans/trans_domain.dart';
import '../domain/topic/topic_domain.dart';
import '../features/selection/projection/selection_projection.dart';
import '../features/selection/selection_args.dart';

class SelectionAdapter {
  SelectionAdapter._();

  static SelectionProjection fromTrans({
    required SelectionType type,
    required List<TransDomain> items,
    required Set<String> selectedIds,
  }) {
    return SelectionProjection(
      title: type.title,
      mode: type.mode,
      items: items
          .where((t) => t.isVisible)
          .map((t) => SelectionItemProjection(
                id: t.id,
                label: t.transName,
                isSelected: selectedIds.contains(t.id),
              ))
          .toList(),
    );
  }

  static SelectionProjection fromMembers({
    required SelectionType type,
    required List<MemberDomain> items,
    required Set<String> selectedIds,
    Set<String> fixedSelectedIds = const {},
  }) {
    return SelectionProjection(
      title: type.title,
      mode: type.mode,
      items: items
          .where((m) => m.isVisible || fixedSelectedIds.contains(m.id))
          .map((m) => SelectionItemProjection(
                id: m.id,
                label: m.memberName,
                isSelected:
                    selectedIds.contains(m.id) || fixedSelectedIds.contains(m.id),
                isFixed: fixedSelectedIds.contains(m.id),
              ))
          .toList(),
    );
  }

  static SelectionProjection fromTags({
    required SelectionType type,
    required List<TagDomain> items,
    required Set<String> selectedIds,
  }) {
    return SelectionProjection(
      title: type.title,
      mode: type.mode,
      items: items
          .where((t) => t.isVisible)
          .map((t) => SelectionItemProjection(
                id: t.id,
                label: t.tagName,
                isSelected: selectedIds.contains(t.id),
              ))
          .toList(),
    );
  }

  static SelectionProjection fromActions({
    required SelectionType type,
    required List<ActionDomain> items,
    required Set<String> selectedIds,
  }) {
    return SelectionProjection(
      title: type.title,
      mode: type.mode,
      items: items
          .where((a) => a.isVisible)
          .map((a) => SelectionItemProjection(
                id: a.id,
                label: a.actionName,
                isSelected: selectedIds.contains(a.id),
              ))
          .toList(),
    );
  }

  static SelectionProjection fromTopics({
    required SelectionType type,
    required List<TopicDomain> items,
    required Set<String> selectedIds,
  }) {
    return SelectionProjection(
      title: type.title,
      mode: type.mode,
      items: items
          .where((t) => t.isVisible)
          .map((t) => SelectionItemProjection(
                id: t.id,
                label: t.topicName,
                isSelected: selectedIds.contains(t.id),
              ))
          .toList(),
    );
  }

  /// draft の selectedIds を反映して Projection を再構築する
  static SelectionProjection rebuild({
    required SelectionProjection current,
    required Set<String> selectedIds,
  }) {
    return SelectionProjection(
      title: current.title,
      mode: current.mode,
      items: current.items
          .map((item) => SelectionItemProjection(
                id: item.id,
                label: item.label,
                subLabel: item.subLabel,
                isSelected: item.isFixed || selectedIds.contains(item.id),
                isFixed: item.isFixed,
              ))
          .toList(),
    );
  }
}
