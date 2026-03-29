import 'package:equatable/equatable.dart';

sealed class ActionSettingDetailEvent extends Equatable {
  const ActionSettingDetailEvent();
}

/// 画面が表示されたとき
///
/// [actionId] が null の場合は新規作成モード
class ActionSettingDetailStarted extends ActionSettingDetailEvent {
  final String? actionId;
  const ActionSettingDetailStarted({this.actionId});

  @override
  List<Object?> get props => [actionId];
}

class ActionSettingDetailNameChanged extends ActionSettingDetailEvent {
  final String value;
  const ActionSettingDetailNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class ActionSettingDetailIsVisibleChanged extends ActionSettingDetailEvent {
  final bool value;
  const ActionSettingDetailIsVisibleChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class ActionSettingDetailSaveTapped extends ActionSettingDetailEvent {
  const ActionSettingDetailSaveTapped();

  @override
  List<Object?> get props => [];
}

class ActionSettingDetailBackTapped extends ActionSettingDetailEvent {
  const ActionSettingDetailBackTapped();

  @override
  List<Object?> get props => [];
}
