import '../domain/invite_code_error_type.dart';
import '../domain/invite_code_member_item.dart';
import '../repository/invitation_repository.dart';

class InviteCodeInputAdapter {
  /// APIレスポンスのmembersリストをDomainに変換する
  static List<InviteCodeMemberItem> toMemberItems(
    List<InviteCodeMemberItem> members,
  ) {
    return List.unmodifiable(members);
  }

  /// APIエラー文字列をInviteCodeErrorTypeに変換する
  static InviteCodeErrorType toErrorType(String errorTypeString) {
    return switch (errorTypeString) {
      'expired' => InviteCodeErrorType.expired,
      'used_up' => InviteCodeErrorType.usedUp,
      'not_found' => InviteCodeErrorType.notFound,
      'already_joined' => InviteCodeErrorType.alreadyJoined,
      'member_already_linked' => InviteCodeErrorType.memberAlreadyLinked,
      _ => InviteCodeErrorType.networkError,
    };
  }

  /// CodeInvitationInfo を必要なフィールドに分解して返すユーティリティ
  static ({String eventName, List<InviteCodeMemberItem> members}) fromCodeInvitationInfo(
    CodeInvitationInfo info,
  ) {
    return (
      eventName: info.eventName,
      members: toMemberItems(info.members),
    );
  }
}
