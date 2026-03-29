import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/event_repository.dart';
import '../draft/mark_detail_draft.dart';
import 'mark_detail_event.dart';
import 'mark_detail_state.dart';

class MarkDetailBloc extends Bloc<MarkDetailEvent, MarkDetailState> {
  MarkDetailBloc({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const MarkDetailLoading()) {
    on<MarkDetailStarted>(_onStarted);
    on<MarkDetailDismissPressed>(_onDismissPressed);
    on<MarkDetailNameChanged>(_onNameChanged);
    on<MarkDetailDateChanged>(_onDateChanged);
    on<MarkDetailEditMembersPressed>(_onEditMembersPressed);
    on<MarkDetailMembersSelected>(_onMembersSelected);
    on<MarkDetailMeterValueChanged>(_onMeterValueChanged);
    on<MarkDetailEditActionsPressed>(_onEditActionsPressed);
    on<MarkDetailActionsSelected>(_onActionsSelected);
    on<MarkDetailMemoChanged>(_onMemoChanged);
    on<MarkDetailIsFuelToggled>(_onIsFuelToggled);
    on<MarkDetailFuelFieldsChanged>(_onFuelFieldsChanged);
  }

  final EventRepository _eventRepository;

  Future<void> _onStarted(
    MarkDetailStarted event,
    Emitter<MarkDetailState> emit,
  ) async {
    emit(const MarkDetailLoading());
    try {
      if (event.markLinkId == null) {
        // 新規作成: 初期Draftを生成
        final draft = MarkDetailDraft(markLinkDate: DateTime.now());
        emit(MarkDetailLoaded(draft: draft));
        return;
      }
      // 既存編集: Repositoryからデータ取得
      final domain = await _eventRepository.fetch(event.eventId);
      final markLink = domain.markLinks
          .where((ml) => ml.id == event.markLinkId && !ml.isDeleted)
          .firstOrNull;
      if (markLink == null) {
        emit(const MarkDetailError(message: 'マークが見つかりません'));
        return;
      }
      final draft = MarkDetailDraft(
        markLinkName: markLink.markLinkName ?? '',
        markLinkDate: markLink.markLinkDate,
        selectedMembers: markLink.members,
        meterValueInput: markLink.meterValue?.toString() ?? '',
        selectedActions: markLink.actions,
        memo: markLink.memo ?? '',
        isFuel: markLink.isFuel,
        pricePerGasInput: markLink.pricePerGas?.toString() ?? '',
        gasQuantityInput: markLink.gasQuantity != null
            ? (markLink.gasQuantity! / 10).toStringAsFixed(1)
            : '',
        gasPriceInput: markLink.gasPrice?.toString() ?? '',
      );
      emit(MarkDetailLoaded(draft: draft));
    } on Exception catch (e) {
      emit(MarkDetailError(message: e.toString()));
    }
  }

  Future<void> _onDismissPressed(
    MarkDetailDismissPressed event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      emit(current.copyWith(delegate: const MarkDetailDismissDelegate()));
    }
  }

  Future<void> _onNameChanged(
    MarkDetailNameChanged event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(markLinkName: event.name),
      ));
    }
  }

  Future<void> _onDateChanged(
    MarkDetailDateChanged event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(markLinkDate: event.date),
      ));
    }
  }

  Future<void> _onEditMembersPressed(
    MarkDetailEditMembersPressed event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      emit(current.copyWith(
        delegate: const MarkDetailOpenMembersSelectionDelegate(),
      ));
    }
  }

  Future<void> _onMembersSelected(
    MarkDetailMembersSelected event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedMembers: event.members),
      ));
    }
  }

  Future<void> _onMeterValueChanged(
    MarkDetailMeterValueChanged event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(meterValueInput: event.input),
      ));
    }
  }

  Future<void> _onEditActionsPressed(
    MarkDetailEditActionsPressed event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      emit(current.copyWith(
        delegate: const MarkDetailOpenActionsSelectionDelegate(),
      ));
    }
  }

  Future<void> _onActionsSelected(
    MarkDetailActionsSelected event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedActions: event.actions),
      ));
    }
  }

  Future<void> _onMemoChanged(
    MarkDetailMemoChanged event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(memo: event.memo),
      ));
    }
  }

  Future<void> _onIsFuelToggled(
    MarkDetailIsFuelToggled event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(isFuel: !current.draft.isFuel),
      ));
    }
  }

  Future<void> _onFuelFieldsChanged(
    MarkDetailFuelFieldsChanged event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(
          pricePerGasInput: event.pricePerGas,
          gasQuantityInput: event.gasQuantity,
          gasPriceInput: event.gasPrice,
        ),
      ));
    }
  }
}
