import 'package:equatable/equatable.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../../domain/master/member/member_domain.dart';

class LinkDetailDraft extends Equatable {
  /// リンク名称（任意）
  final String markLinkName;

  /// 記録日（保持用。LinkDetailでは編集不可）
  final DateTime markLinkDate;

  /// 走行距離入力文字列（例: "123"。未入力時は空文字）
  final String distanceValueInput;

  /// 選択中のメンバー
  final List<MemberDomain> selectedMembers;

  /// 選択中のアクション
  final List<ActionDomain> selectedActions;

  /// メモ（任意）
  final String memo;

  const LinkDetailDraft({
    this.markLinkName = '',
    required this.markLinkDate,
    this.distanceValueInput = '',
    this.selectedMembers = const [],
    this.selectedActions = const [],
    this.memo = '',
  });

  LinkDetailDraft copyWith({
    String? markLinkName,
    DateTime? markLinkDate,
    String? distanceValueInput,
    List<MemberDomain>? selectedMembers,
    List<ActionDomain>? selectedActions,
    String? memo,
  }) {
    return LinkDetailDraft(
      markLinkName: markLinkName ?? this.markLinkName,
      markLinkDate: markLinkDate ?? this.markLinkDate,
      distanceValueInput: distanceValueInput ?? this.distanceValueInput,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      selectedActions: selectedActions ?? this.selectedActions,
      memo: memo ?? this.memo,
    );
  }

  @override
  List<Object?> get props => [
        markLinkName,
        markLinkDate,
        distanceValueInput,
        selectedMembers,
        selectedActions,
        memo,
      ];
}
