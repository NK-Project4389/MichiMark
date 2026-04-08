import '../../../domain/master/member/member_domain.dart';

/// go_router の extra 経由で選択画面に渡す引数
class SelectionArgs {
  final SelectionType type;

  /// 現在選択済みのIDセット（初期選択状態の設定に使用）
  final Set<String> selectedIds;

  /// 常にON固定にするIDセット（割り勘の支払者など）
  final Set<String> fixedSelectedIds;

  /// メンバー選択候補（指定した場合は MemberRepository.fetchAll() を使わずこのリストを使用する）
  /// REQ-MAD-004: MarkDetail のメンバー選択候補をイベントメンバーに限定するために使用
  final List<MemberDomain>? candidateMembers;

  const SelectionArgs({
    required this.type,
    this.selectedIds = const {},
    this.fixedSelectedIds = const {},
    this.candidateMembers,
  });
}

// ---------------------------------------------------------------------------

enum SelectionType {
  eventTrans,
  eventMembers,
  eventTags,
  gasPayMember,
  markMembers,
  markActions,
  linkMembers,
  linkActions,
  payMember,
  splitMembers,
  eventTopic,
}

enum SelectionMode { single, multiple }

extension SelectionTypeExt on SelectionType {
  SelectionMode get mode => switch (this) {
        SelectionType.eventTrans => SelectionMode.single,
        SelectionType.gasPayMember => SelectionMode.single,
        SelectionType.payMember => SelectionMode.single,
        SelectionType.eventTopic => SelectionMode.single,
        _ => SelectionMode.multiple,
      };

  String get title => switch (this) {
        SelectionType.eventTrans => '交通手段を選択',
        SelectionType.eventMembers => 'メンバーを選択',
        SelectionType.eventTags => 'タグを選択',
        SelectionType.gasPayMember => 'ガソリン支払者を選択',
        SelectionType.markMembers => 'メンバーを選択',
        SelectionType.markActions => 'アクションを選択',
        SelectionType.linkMembers => 'メンバーを選択',
        SelectionType.linkActions => 'アクションを選択',
        SelectionType.payMember => '支払者を選択',
        SelectionType.splitMembers => '割り勘メンバーを選択',
        SelectionType.eventTopic => 'トピックを選択',
      };
}
