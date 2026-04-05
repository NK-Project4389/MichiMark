import 'package:equatable/equatable.dart';
import '../../../../domain/action_time/action_state.dart';

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

/// 遷移後状態が変更されたとき（null = 状態変化なし）
class ActionSettingDetailToStateChanged extends ActionSettingDetailEvent {
  final ActionState? value;
  const ActionSettingDetailToStateChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// トグルフラグが変更されたとき
class ActionSettingDetailIsToggleChanged extends ActionSettingDetailEvent {
  final bool value;
  const ActionSettingDetailIsToggleChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// needsTransitionフラグが変更されたとき（REQ-005）
class ActionSettingDetailNeedsTransitionChanged extends ActionSettingDetailEvent {
  final bool value;
  const ActionSettingDetailNeedsTransitionChanged(this.value);

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
