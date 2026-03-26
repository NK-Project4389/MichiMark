import 'package:equatable/equatable.dart';

class MemberItemProjection extends Equatable {
  final String id;
  final String memberName;
  final String? mailAddress;
  final bool isVisible;

  const MemberItemProjection({
    required this.id,
    required this.memberName,
    this.mailAddress,
    required this.isVisible,
  });

  @override
  List<Object?> get props => [id, memberName, mailAddress, isVisible];
}
