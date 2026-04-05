import 'package:equatable/equatable.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();
}

/// 「イベント一覧へ戻る」ボタンタップ時（REQ-006）
class SettingsNavigateToEventsRequested extends SettingsEvent {
  const SettingsNavigateToEventsRequested();

  @override
  List<Object?> get props => [];
}
