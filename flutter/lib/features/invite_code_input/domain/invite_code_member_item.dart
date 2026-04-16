import 'package:equatable/equatable.dart';

class InviteCodeMemberItem extends Equatable {
  final String memberId;
  final String memberName;

  const InviteCodeMemberItem({
    required this.memberId,
    required this.memberName,
  });

  @override
  List<Object?> get props => [memberId, memberName];
}
