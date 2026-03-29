import 'package:equatable/equatable.dart';

sealed class TagSettingDetailEvent extends Equatable {
  const TagSettingDetailEvent();
}

/// 画面が表示されたとき
///
/// [tagId] が null の場合は新規作成モード
class TagSettingDetailStarted extends TagSettingDetailEvent {
  final String? tagId;
  const TagSettingDetailStarted({this.tagId});

  @override
  List<Object?> get props => [tagId];
}

class TagSettingDetailNameChanged extends TagSettingDetailEvent {
  final String value;
  const TagSettingDetailNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class TagSettingDetailIsVisibleChanged extends TagSettingDetailEvent {
  final bool value;
  const TagSettingDetailIsVisibleChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class TagSettingDetailSaveTapped extends TagSettingDetailEvent {
  const TagSettingDetailSaveTapped();

  @override
  List<Object?> get props => [];
}

class TagSettingDetailBackTapped extends TagSettingDetailEvent {
  const TagSettingDetailBackTapped();

  @override
  List<Object?> get props => [];
}
