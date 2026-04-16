import 'package:equatable/equatable.dart';

/// 招待リンク生成結果を表すDomainモデル。
class InviteLinkShareResult extends Equatable {
  final String token;
  final String code;
  final String inviteUrl;
  final DateTime expiresAt;

  const InviteLinkShareResult({
    required this.token,
    required this.code,
    required this.inviteUrl,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [token, code, inviteUrl, expiresAt];
}
