import 'package:equatable/equatable.dart';

/// Repositoryから返る招待リンク生成レスポンス型。
class CreateInvitationResponse extends Equatable {
  final String token;
  final String code;
  final DateTime expiresAt;
  final String inviteUrl;

  const CreateInvitationResponse({
    required this.token,
    required this.code,
    required this.expiresAt,
    required this.inviteUrl,
  });

  @override
  List<Object?> get props => [token, code, expiresAt, inviteUrl];
}
