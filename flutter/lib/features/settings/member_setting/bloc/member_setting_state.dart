import 'package:equatable/equatable.dart';
import '../../../../features/shared/projection/member_item_projection.dart';

// ── Delegate ─────────────────────────────────────────────────────────────────

sealed class MemberSettingDelegate extends Equatable {
  const MemberSettingDelegate();
}

class MemberSettingOpenDetailDelegate extends MemberSettingDelegate {
  final String memberId;
  const MemberSettingOpenDetailDelegate(this.memberId);

  @override
  List<Object?> get props => [memberId];
}

class MemberSettingOpenNewDelegate extends MemberSettingDelegate {
  const MemberSettingOpenNewDelegate();

  @override
  List<Object?> get props => [];
}

// ── State ─────────────────────────────────────────────────────────────────────

sealed class MemberSettingState extends Equatable {
  const MemberSettingState();
}

class MemberSettingLoading extends MemberSettingState {
  const MemberSettingLoading();

  @override
  List<Object?> get props => [];
}

class MemberSettingLoaded extends MemberSettingState {
  final List<MemberItemProjection> items;
  final MemberSettingDelegate? delegate;

  const MemberSettingLoaded({
    required this.items,
    this.delegate,
  });

  MemberSettingLoaded copyWith({
    List<MemberItemProjection>? items,
    MemberSettingDelegate? delegate,
  }) {
    return MemberSettingLoaded(
      items: items ?? this.items,
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props => [items, delegate];
}

class MemberSettingError extends MemberSettingState {
  final String message;
  const MemberSettingError(this.message);

  @override
  List<Object?> get props => [message];
}
