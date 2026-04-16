import 'package:equatable/equatable.dart';

/// 招待リンク生成設定のDraft専用権限enum。
/// Domain層のInvitationRole（owner/editor/viewer）とは別の型。
/// ownerはユーザーが選択する権限ではないため含まない。
enum InviteLinkRole {
  editor,
  viewer;

  String get displayLabel => switch (this) {
        InviteLinkRole.editor => '編集可能',
        InviteLinkRole.viewer => '閲覧のみ',
      };

  String get apiValue => switch (this) {
        InviteLinkRole.editor => 'editor',
        InviteLinkRole.viewer => 'viewer',
      };
}

/// 招待設定の編集状態を保持するDraft。
class InviteLinkShareDraft extends Equatable {
  final InviteLinkRole role;
  final int expiresHours;
  final int? maxUses;

  const InviteLinkShareDraft({
    this.role = InviteLinkRole.editor,
    this.expiresHours = 24,
    this.maxUses = 1,
  });

  InviteLinkShareDraft copyWith({
    InviteLinkRole? role,
    int? expiresHours,
    int? Function()? maxUses,
  }) {
    return InviteLinkShareDraft(
      role: role ?? this.role,
      expiresHours: expiresHours ?? this.expiresHours,
      maxUses: maxUses != null ? maxUses() : this.maxUses,
    );
  }

  @override
  List<Object?> get props => [role, expiresHours, maxUses];
}
