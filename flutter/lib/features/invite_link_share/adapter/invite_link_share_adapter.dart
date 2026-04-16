import '../domain/create_invitation_request.dart';
import '../domain/create_invitation_response.dart';
import '../domain/invite_link_share_result.dart';
import '../draft/invite_link_share_draft.dart';

/// Draft -> APIリクエスト、APIレスポンス -> Domain結果型の変換を行うAdapter。
class InviteLinkShareAdapter {
  const InviteLinkShareAdapter._();

  /// Draft + コンテキスト情報 -> APIリクエスト型への変換。
  /// orgId は ownerのuid と同一。
  static CreateInvitationRequest toCreateRequest(
    InviteLinkShareDraft draft,
    String eventId,
    String uid,
  ) {
    return CreateInvitationRequest(
      orgId: uid,
      eventId: eventId,
      invitedBy: uid,
      role: draft.role.apiValue,
      expiresHours: draft.expiresHours,
      maxUses: draft.maxUses,
    );
  }

  /// APIレスポンス -> Domain結果型への変換。
  static InviteLinkShareResult toResult(CreateInvitationResponse response) {
    return InviteLinkShareResult(
      token: response.token,
      code: response.code,
      inviteUrl: response.inviteUrl,
      expiresAt: response.expiresAt,
    );
  }
}
