import 'package:equatable/equatable.dart';

/// Repositoryに渡す招待リンク生成リクエスト型。
class CreateInvitationRequest extends Equatable {
  final String orgId;
  final String eventId;
  final String invitedBy;
  final String role;
  final int expiresHours;
  final int? maxUses;

  const CreateInvitationRequest({
    required this.orgId,
    required this.eventId,
    required this.invitedBy,
    required this.role,
    required this.expiresHours,
    this.maxUses,
  });

  @override
  List<Object?> get props => [orgId, eventId, invitedBy, role, expiresHours, maxUses];
}
