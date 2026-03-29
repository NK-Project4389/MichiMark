import 'package:equatable/equatable.dart';

sealed class ActionSettingEvent extends Equatable {
  const ActionSettingEvent();
}

class ActionSettingStarted extends ActionSettingEvent {
  const ActionSettingStarted();

  @override
  List<Object?> get props => [];
}

class ActionSettingItemSelected extends ActionSettingEvent {
  final String actionId;
  const ActionSettingItemSelected(this.actionId);

  @override
  List<Object?> get props => [actionId];
}

class ActionSettingAddTapped extends ActionSettingEvent {
  const ActionSettingAddTapped();

  @override
  List<Object?> get props => [];
}
