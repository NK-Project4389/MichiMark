import '../../../../domain/invitation/invitation_role.dart';
import '../../../invite_link_share/domain/create_invitation_request.dart';
import '../../../invite_link_share/domain/create_invitation_response.dart';
import '../../bloc/invite_code_input_bloc.dart';
import '../../domain/invite_code_member_item.dart';
import '../invitation_repository.dart';

/// スタブ実装（Integration Test用）
///
/// 特定コードに対してエラー種別を返す:
///   EXP-XXXX → expired エラー
///   NUL-XXXX → not_found エラー
///   ERR-XXXX → networkError（UnimplementedError）
///   その他の有効フォーマット → 成功レスポンス（ダミーデータ）
class StubInvitationRepository implements InvitationRepository {
  const StubInvitationRepository();

  @override
  Future<CodeInvitationInfo> getInvitationByCode(String code) async {
    final prefix = code.length >= 3 ? code.substring(0, 3) : '';
    switch (prefix) {
      case 'EXP':
        throw const InviteCodeApiException('expired');
      case 'NUL':
        throw const InviteCodeApiException('not_found');
      case 'ERR':
        throw UnimplementedError('GET /api/invitations/code/[code] is not implemented yet.');
      default:
        return CodeInvitationInfo(
          token: 'stub-token-001',
          eventName: 'スタブイベント',
          inviterName: 'スタブ招待者',
          role: 'viewer',
          members: [
            InviteCodeMemberItem(memberId: 'member-001', memberName: '山田 太郎'),
            InviteCodeMemberItem(memberId: 'member-002', memberName: '田中 花子'),
          ],
        );
    }
  }

  @override
  Future<JoinResult> joinByCode({
    required String code,
    required String uid,
    required String memberId,
  }) async {
    final prefix = code.length >= 3 ? code.substring(0, 3) : '';
    switch (prefix) {
      case 'ALR':
        throw const InviteCodeApiException('already_joined');
      case 'ERR':
        throw UnimplementedError('POST /api/invitations/code is not implemented yet.');
      default:
        return const JoinResult(eventId: 'stub-event-001', role: 'viewer');
    }
  }

  @override
  Future<CreateInvitationResponse> createInvitation(
    CreateInvitationRequest request,
  ) async {
    return CreateInvitationResponse(
      token: 'stub-token-inv4',
      code: 'STB-0001',
      expiresAt: DateTime.now().add(Duration(hours: request.expiresHours)),
      inviteUrl: 'https://michimark.example.com/invite/stub-token-inv4',
    );
  }

  @override
  Future<InvitationRole> fetchUserRole(String eventId) async {
    return InvitationRole.owner;
  }
}
