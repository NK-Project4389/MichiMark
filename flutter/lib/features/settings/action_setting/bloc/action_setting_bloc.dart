import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../adapter/settings_adapter.dart';
import '../../../../repository/action_repository.dart';
import 'action_setting_event.dart';
import 'action_setting_state.dart';

class ActionSettingBloc extends Bloc<ActionSettingEvent, ActionSettingState> {
  ActionSettingBloc({required ActionRepository actionRepository})
      : _actionRepository = actionRepository,
        super(const ActionSettingLoading()) {
    on<ActionSettingStarted>(_onStarted);
    on<ActionSettingItemSelected>(_onItemSelected);
    on<ActionSettingAddTapped>(_onAddTapped);
  }

  final ActionRepository _actionRepository;

  Future<void> _onStarted(
    ActionSettingStarted event,
    Emitter<ActionSettingState> emit,
  ) async {
    emit(const ActionSettingLoading());
    try {
      final domains = await _actionRepository.fetchAll();
      final items = domains.map(SettingsAdapter.toActionProjection).toList();
      emit(ActionSettingLoaded(items: items));
    } on Exception catch (e) {
      emit(ActionSettingError(e.toString()));
    }
  }

  Future<void> _onItemSelected(
    ActionSettingItemSelected event,
    Emitter<ActionSettingState> emit,
  ) async {
    if (state is ActionSettingLoaded) {
      final current = state as ActionSettingLoaded;
      emit(current.copyWith(
        delegate: ActionSettingOpenDetailDelegate(event.actionId),
      ));
    }
  }

  Future<void> _onAddTapped(
    ActionSettingAddTapped event,
    Emitter<ActionSettingState> emit,
  ) async {
    if (state is ActionSettingLoaded) {
      final current = state as ActionSettingLoaded;
      emit(current.copyWith(delegate: const ActionSettingOpenNewDelegate()));
    }
  }
}
