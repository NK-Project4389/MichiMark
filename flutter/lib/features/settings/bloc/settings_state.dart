import 'package:equatable/equatable.dart';

/// SettingsのDelegate（画面遷移・操作意図の通知）
sealed class SettingsDelegate extends Equatable {
  const SettingsDelegate();
}

/// イベント一覧画面（/events）への遷移を通知する（REQ-006）
class SettingsNavigateToEventsDelegate extends SettingsDelegate {
  const SettingsNavigateToEventsDelegate();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------

class SettingsState extends Equatable {
  final SettingsDelegate? delegate;

  const SettingsState({this.delegate});

  SettingsState copyWith({SettingsDelegate? delegate}) {
    return SettingsState(delegate: delegate);
  }

  @override
  List<Object?> get props => [delegate];
}
