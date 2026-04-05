import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsNavigateToEventsRequested>(_onNavigateToEventsRequested);
  }

  Future<void> _onNavigateToEventsRequested(
    SettingsNavigateToEventsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      delegate: const SettingsNavigateToEventsDelegate(),
    ));
  }
}
