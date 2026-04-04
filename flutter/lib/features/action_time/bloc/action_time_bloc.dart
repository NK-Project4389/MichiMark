import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../adapter/action_time_adapter.dart';
import '../../../domain/action_time/action_state.dart';
import '../../../domain/action_time/action_time_log.dart';
import '../../../repository/action_repository.dart';
import '../../../repository/event_repository.dart';
import '../draft/action_time_draft.dart';
import '../projection/action_time_projection.dart';
import 'action_time_event.dart';
import 'action_time_state.dart';

class ActionTimeBloc extends Bloc<ActionTimeEvent, ActionTimeState> {
  ActionTimeBloc({
    required EventRepository eventRepository,
    required ActionRepository actionRepository,
  })  : _eventRepository = eventRepository,
        _actionRepository = actionRepository,
        super(ActionTimeState(
          draft: const ActionTimeDraft(eventId: ''),
          projection: const ActionTimeProjection(
            currentStateLabel: '待機中',
            logItems: [],
            isBreakActive: false,
          ),
        )) {
    on<ActionTimeStarted>(_onStarted);
    on<ActionTimeLogRecorded>(_onLogRecorded);
    on<ActionTimeBreakToggled>(_onBreakToggled);
    on<ActionTimeLogDeleted>(_onLogDeleted);
  }

  final EventRepository _eventRepository;
  final ActionRepository _actionRepository;

  Future<void> _onStarted(
    ActionTimeStarted event,
    Emitter<ActionTimeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    try {
      final logs = await _eventRepository.fetchActionTimeLogs(event.eventId);
      final allActions = await _actionRepository.fetchAll();
      final (draft, projection) = ActionTimeAdapter.buildDraftAndProjection(
        eventId: event.eventId,
        logs: logs,
        allActions: allActions,
      );
      emit(state.copyWith(
        draft: draft,
        projection: projection,
        isLoading: false,
      ));
    } on Exception catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLogRecorded(
    ActionTimeLogRecorded event,
    Emitter<ActionTimeState> emit,
  ) async {
    final eventId = state.draft.eventId;
    if (eventId.isEmpty) return;

    try {
      final now = DateTime.now();
      final log = ActionTimeLog(
        id: const Uuid().v4(),
        eventId: eventId,
        actionId: event.actionId,
        timestamp: now,
        createdAt: now,
        updatedAt: now,
      );
      await _eventRepository.saveActionTimeLog(log);
      await _refreshState(eventId, emit);
    } on Exception catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onBreakToggled(
    ActionTimeBreakToggled event,
    Emitter<ActionTimeState> emit,
  ) async {
    final eventId = state.draft.eventId;
    if (eventId.isEmpty) return;

    final allActions = await _actionRepository.fetchAll();
    final isBreakActive = state.projection.isBreakActive;

    // 休憩中 → 休憩終了Action（break_ → working）、そうでない場合 → 休憩開始Action（working → break_）を探す
    // isBreakActive == true なら break_ → working (休憩終了) を探す
    // isBreakActive == false なら working → break_ (休憩開始) を探す
    final action = allActions.where((a) {
      if (isBreakActive) {
        return a.fromState == ActionState.break_ && a.toState == ActionState.working;
      } else {
        return a.fromState == ActionState.working && a.toState == ActionState.break_;
      }
    }).firstOrNull;

    if (action == null) return;

    try {
      final now = DateTime.now();
      final log = ActionTimeLog(
        id: const Uuid().v4(),
        eventId: eventId,
        actionId: action.id,
        timestamp: now,
        createdAt: now,
        updatedAt: now,
      );
      await _eventRepository.saveActionTimeLog(log);
      await _refreshState(eventId, emit);
    } on Exception catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onLogDeleted(
    ActionTimeLogDeleted event,
    Emitter<ActionTimeState> emit,
  ) async {
    final eventId = state.draft.eventId;
    try {
      await _eventRepository.deleteActionTimeLog(event.logId);
      await _refreshState(eventId, emit);
    } on Exception catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _refreshState(
    String eventId,
    Emitter<ActionTimeState> emit,
  ) async {
    final logs = await _eventRepository.fetchActionTimeLogs(eventId);
    final allActions = await _actionRepository.fetchAll();
    final (draft, projection) = ActionTimeAdapter.buildDraftAndProjection(
      eventId: eventId,
      logs: logs,
      allActions: allActions,
    );
    emit(state.copyWith(draft: draft, projection: projection));
  }
}
