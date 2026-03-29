import 'package:equatable/equatable.dart';

sealed class MemberSettingDetailEvent extends Equatable {
  const MemberSettingDetailEvent();
}

/// 画面が表示されたとき
///
/// [memberId] が null の場合は新規作成モード
class MemberSettingDetailStarted extends MemberSettingDetailEvent {
  final String? memberId;
  const MemberSettingDetailStarted({this.memberId});

  @override
  List<Object?> get props => [memberId];
}

class MemberSettingDetailNameChanged extends MemberSettingDetailEvent {
  final String value;
  const MemberSettingDetailNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class MemberSettingDetailIsVisibleChanged extends MemberSettingDetailEvent {
  final bool value;
  const MemberSettingDetailIsVisibleChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class MemberSettingDetailSaveTapped extends MemberSettingDetailEvent {
  const MemberSettingDetailSaveTapped();

  @override
  List<Object?> get props => [];
}

class MemberSettingDetailBackTapped extends MemberSettingDetailEvent {
  const MemberSettingDetailBackTapped();

  @override
  List<Object?> get props => [];
}
