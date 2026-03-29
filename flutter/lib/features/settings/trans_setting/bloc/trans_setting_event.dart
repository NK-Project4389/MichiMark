import 'package:equatable/equatable.dart';

sealed class TransSettingEvent extends Equatable {
  const TransSettingEvent();
}

class TransSettingStarted extends TransSettingEvent {
  const TransSettingStarted();

  @override
  List<Object?> get props => [];
}

class TransSettingItemSelected extends TransSettingEvent {
  final String transId;
  const TransSettingItemSelected(this.transId);

  @override
  List<Object?> get props => [transId];
}

class TransSettingAddTapped extends TransSettingEvent {
  const TransSettingAddTapped();

  @override
  List<Object?> get props => [];
}
