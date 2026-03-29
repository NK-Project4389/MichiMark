import 'package:equatable/equatable.dart';

sealed class MemberSettingEvent extends Equatable {
  const MemberSettingEvent();
}

class MemberSettingStarted extends MemberSettingEvent {
  const MemberSettingStarted();

  @override
  List<Object?> get props => [];
}

class MemberSettingItemSelected extends MemberSettingEvent {
  final String memberId;
  const MemberSettingItemSelected(this.memberId);

  @override
  List<Object?> get props => [memberId];
}

class MemberSettingAddTapped extends MemberSettingEvent {
  const MemberSettingAddTapped();

  @override
  List<Object?> get props => [];
}
