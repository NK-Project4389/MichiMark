import 'package:equatable/equatable.dart';

sealed class TagSettingEvent extends Equatable {
  const TagSettingEvent();
}

class TagSettingStarted extends TagSettingEvent {
  const TagSettingStarted();

  @override
  List<Object?> get props => [];
}

class TagSettingItemSelected extends TagSettingEvent {
  final String tagId;
  const TagSettingItemSelected(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

class TagSettingAddTapped extends TagSettingEvent {
  const TagSettingAddTapped();

  @override
  List<Object?> get props => [];
}
