import 'package:equatable/equatable.dart';

import '../draft/invite_link_share_draft.dart';

sealed class InviteLinkShareEvent extends Equatable {
  const InviteLinkShareEvent();
}

/// BottomSheet表示時に発火。eventIdを受け取って初期化する。
class InviteLinkShareStarted extends InviteLinkShareEvent {
  const InviteLinkShareStarted();

  @override
  List<Object?> get props => [];
}

/// 権限ラジオボタン変更時。
class InviteLinkRoleChanged extends InviteLinkShareEvent {
  final InviteLinkRole role;
  const InviteLinkRoleChanged(this.role);

  @override
  List<Object?> get props => [role];
}

/// 有効期限ボタン変更時。
class InviteLinkExpiresHoursChanged extends InviteLinkShareEvent {
  final int expiresHours;
  const InviteLinkExpiresHoursChanged(this.expiresHours);

  @override
  List<Object?> get props => [expiresHours];
}

/// 使用回数ボタン変更時。
class InviteLinkMaxUsesChanged extends InviteLinkShareEvent {
  final int? maxUses;
  const InviteLinkMaxUsesChanged(this.maxUses);

  @override
  List<Object?> get props => [maxUses];
}

/// 「招待リンクを作成」ボタンタップ時。
class InviteLinkCreatePressed extends InviteLinkShareEvent {
  const InviteLinkCreatePressed();

  @override
  List<Object?> get props => [];
}
