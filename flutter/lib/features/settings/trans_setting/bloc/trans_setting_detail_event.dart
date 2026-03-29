import 'package:equatable/equatable.dart';

sealed class TransSettingDetailEvent extends Equatable {
  const TransSettingDetailEvent();
}

/// 画面が表示されたとき
///
/// [transId] が null の場合は新規作成モード
class TransSettingDetailStarted extends TransSettingDetailEvent {
  final String? transId;
  const TransSettingDetailStarted({this.transId});

  @override
  List<Object?> get props => [transId];
}

class TransSettingDetailNameChanged extends TransSettingDetailEvent {
  final String value;
  const TransSettingDetailNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class TransSettingDetailKmPerGasChanged extends TransSettingDetailEvent {
  final String value;
  const TransSettingDetailKmPerGasChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class TransSettingDetailMeterValueChanged extends TransSettingDetailEvent {
  final String value;
  const TransSettingDetailMeterValueChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class TransSettingDetailIsVisibleChanged extends TransSettingDetailEvent {
  final bool value;
  const TransSettingDetailIsVisibleChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class TransSettingDetailSaveTapped extends TransSettingDetailEvent {
  const TransSettingDetailSaveTapped();

  @override
  List<Object?> get props => [];
}

class TransSettingDetailBackTapped extends TransSettingDetailEvent {
  const TransSettingDetailBackTapped();

  @override
  List<Object?> get props => [];
}
