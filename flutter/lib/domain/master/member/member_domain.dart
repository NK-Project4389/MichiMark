import 'package:equatable/equatable.dart';

class MemberDomain extends Equatable {
  final String id;

  /// 表示名（入力必須）
  final String memberName;

  /// メールアドレス（将来拡張：共有・招待・通知など）
  final String? mailAddress;

  /// 表示フラグ（true: 表示 / false: 非表示）
  final bool isVisible;

  /// 論理削除フラグ
  final bool isDeleted;

  /// 登録日（初回のみ設定）
  final DateTime createdAt;

  /// 更新日（保存時更新）
  final DateTime updatedAt;

  const MemberDomain({
    required this.id,
    required this.memberName,
    this.mailAddress,
    this.isVisible = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  MemberDomain copyWith({
    String? id,
    String? memberName,
    String? mailAddress,
    bool? isVisible,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemberDomain(
      id: id ?? this.id,
      memberName: memberName ?? this.memberName,
      mailAddress: mailAddress ?? this.mailAddress,
      isVisible: isVisible ?? this.isVisible,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        memberName,
        mailAddress,
        isVisible,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
