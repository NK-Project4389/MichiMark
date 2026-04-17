import '../../../../domain/invitation/invitation_role.dart';
import '../../invite_link_share/domain/create_invitation_request.dart';
import '../../invite_link_share/domain/create_invitation_response.dart';
import '../domain/invite_code_member_item.dart';

/// 招待コード検証APIレスポンス（成功時）
class CodeInvitationInfo {
  final String token;
  final String eventName;
  final String inviterName;
  final String role;
  final List<InviteCodeMemberItem> members;

  const CodeInvitationInfo({
    required this.token,
    required this.eventName,
    required this.inviterName,
    required this.role,
    required this.members,
  });
}

/// 参加確定APIレスポンス（成功時）
class JoinResult {
  final String eventId;
  final String role;

  const JoinResult({required this.eventId, required this.role});
}

abstract class InvitationRepository {
  /// GET /api/invitations/code/[code]
  /// コード検証 + メンバー一覧取得
  Future<CodeInvitationInfo> getInvitationByCode(String code);

  /// POST /api/invitations/code
  /// 参加確定
  Future<JoinResult> joinByCode({
    required String code,
    required String uid,
    required String memberId,
  });

  /// POST /api/invitations
  /// 招待リンク生成
  Future<CreateInvitationResponse> createInvitation(
    CreateInvitationRequest request,
  );

  /// GET /api/invitations/events/[eventId]/role
  /// 現在のユーザーのイベント内権限を取得する
  Future<InvitationRole> fetchUserRole(String eventId);
}
