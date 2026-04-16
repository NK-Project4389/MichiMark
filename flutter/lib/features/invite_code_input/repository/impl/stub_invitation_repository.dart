import '../invitation_repository.dart';

/// スタブ実装（APIが未実装のため全メソッドをUnimplementedErrorでスタブ）
class StubInvitationRepository implements InvitationRepository {
  const StubInvitationRepository();

  @override
  Future<CodeInvitationInfo> getInvitationByCode(String code) {
    throw UnimplementedError('GET /api/invitations/code/[code] is not implemented yet.');
  }

  @override
  Future<JoinResult> joinByCode({
    required String code,
    required String uid,
    required String memberId,
  }) {
    throw UnimplementedError('POST /api/invitations/code is not implemented yet.');
  }
}
