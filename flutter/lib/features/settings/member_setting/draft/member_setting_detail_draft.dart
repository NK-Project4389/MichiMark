import 'package:equatable/equatable.dart';

class MemberSettingDetailDraft extends Equatable {
  final String memberName;
  final bool isVisible;

  const MemberSettingDetailDraft({
    this.memberName = '',
    this.isVisible = true,
  });

  MemberSettingDetailDraft copyWith({
    String? memberName,
    bool? isVisible,
  }) {
    return MemberSettingDetailDraft(
      memberName: memberName ?? this.memberName,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object?> get props => [memberName, isVisible];
}
