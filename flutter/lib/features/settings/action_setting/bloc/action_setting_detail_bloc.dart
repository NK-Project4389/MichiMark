import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/master/action/action_domain.dart';
import '../../../../repository/action_repository.dart';
import '../draft/action_setting_detail_draft.dart';
import 'action_setting_detail_event.dart';
import 'action_setting_detail_state.dart';

class ActionSettingDetailBloc
    extends Bloc<ActionSettingDetailEvent, ActionSettingDetailState> {
  ActionSettingDetailBloc({required ActionRepository actionRepository})
      : _actionRepository = actionRepository,
        super(const ActionSettingDetailLoading()) {
    on<ActionSettingDetailStarted>(_onStarted);
    on<ActionSettingDetailNameChanged>(_onNameChanged);
    on<ActionSettingDetailIsVisibleChanged>(_onIsVisibleChanged);
    on<ActionSettingDetailToStateChanged>(_onToStateChanged);
    on<ActionSettingDetailIsToggleChanged>(_onIsToggleChanged);
    on<ActionSettingDetailNeedsTransitionChanged>(_onNeedsTransitionChanged);
    on<ActionSettingDetailSaveTapped>(_onSaveTapped);
    on<ActionSettingDetailBackTapped>(_onBackTapped);
  }

  final ActionRepository _actionRepository;

  Future<void> _onStarted(
    ActionSettingDetailStarted event,
    Emitter<ActionSettingDetailState> emit,
  ) async {
    emit(const ActionSettingDetailLoading());

    if (event.actionId == null) {
      final newId = const Uuid().v4();
      emit(ActionSettingDetailLoaded(
        actionId: newId,
        draft: const ActionSettingDetailDraft(),
      ));
      return;
    }

    try {
      final all = await _actionRepository.fetchAll();
      final domain = all.where((a) => a.id == event.actionId).firstOrNull;
      if (domain == null) {
        emit(const ActionSettingDetailError('行動が見つかりません'));
        return;
      }
      emit(ActionSettingDetailLoaded(
        actionId: domain.id,
        draft: ActionSettingDetailDraft(
          actionName: domain.actionName,
          isVisible: domain.isVisible,
          toState: domain.toState,
          isToggle: domain.isToggle,
          togglePairId: domain.togglePairId,
          needsTransition: domain.needsTransition,
        ),
      ));
    } on Exception catch (e) {
      emit(ActionSettingDetailError(e.toString()));
    }
  }

  Future<void> _onNameChanged(
    ActionSettingDetailNameChanged event,
    Emitter<ActionSettingDetailState> emit,
  ) async {
    if (state is ActionSettingDetailLoaded) {
      final current = state as ActionSettingDetailLoaded;
      final isBlank = event.value.trim().isEmpty;
      emit(current.copyWith(
        draft: current.draft.copyWith(actionName: event.value),
        validationError: isBlank ? '空欄' : null,
        clearValidationError: !isBlank,
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onIsVisibleChanged(
    ActionSettingDetailIsVisibleChanged event,
    Emitter<ActionSettingDetailState> emit,
  ) async {
    if (state is ActionSettingDetailLoaded) {
      final current = state as ActionSettingDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(isVisible: event.value),
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onToStateChanged(
    ActionSettingDetailToStateChanged event,
    Emitter<ActionSettingDetailState> emit,
  ) async {
    if (state is ActionSettingDetailLoaded) {
      final current = state as ActionSettingDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(
          toState: event.value,
          clearToState: event.value == null,
        ),
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onIsToggleChanged(
    ActionSettingDetailIsToggleChanged event,
    Emitter<ActionSettingDetailState> emit,
  ) async {
    if (state is ActionSettingDetailLoaded) {
      final current = state as ActionSettingDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(isToggle: event.value),
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onNeedsTransitionChanged(
    ActionSettingDetailNeedsTransitionChanged event,
    Emitter<ActionSettingDetailState> emit,
  ) async {
    if (state is ActionSettingDetailLoaded) {
      final current = state as ActionSettingDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(needsTransition: event.value),
        clearSaveError: true,
      ));
    }
  }

  Future<void> _onSaveTapped(
    ActionSettingDetailSaveTapped event,
    Emitter<ActionSettingDetailState> emit,
  ) async {
    if (state is! ActionSettingDetailLoaded) return;
    final current = state as ActionSettingDetailLoaded;

    if (current.draft.actionName.trim().isEmpty) {
      emit(current.copyWith(
        validationError: '行動名を入力してください',
      ));
      return;
    }

    emit(current.copyWith(isSaving: true, clearSaveError: true));

    try {
      final now = DateTime.now();
      final all = await _actionRepository.fetchAll();
      final existing = all.where((a) => a.id == current.actionId).firstOrNull;

      final domain = ActionDomain(
        id: current.actionId,
        actionName: current.draft.actionName.trim(),
        isVisible: current.draft.isVisible,
        isDeleted: false,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        toState: current.draft.toState,
        isToggle: current.draft.isToggle,
        togglePairId: current.draft.togglePairId,
        needsTransition: current.draft.needsTransition,
      );

      await _actionRepository.save(domain);

      emit(current.copyWith(
        isSaving: false,
        delegate: const ActionSettingDetailDidSaveDelegate(),
      ));
    } on Exception catch (e) {
      final loaded = state as ActionSettingDetailLoaded;
      emit(loaded.copyWith(
        isSaving: false,
        saveErrorMessage: '保存に失敗しました: ${e.toString()}',
      ));
    }
  }

  Future<void> _onBackTapped(
    ActionSettingDetailBackTapped event,
    Emitter<ActionSettingDetailState> emit,
  ) async {
    if (state is ActionSettingDetailLoaded) {
      final current = state as ActionSettingDetailLoaded;
      emit(current.copyWith(
        delegate: const ActionSettingDetailDismissDelegate(),
      ));
    }
  }
}
