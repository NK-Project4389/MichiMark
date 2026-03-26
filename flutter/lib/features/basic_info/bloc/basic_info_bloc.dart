import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/event_repository.dart';
import '../draft/basic_info_draft.dart';
import 'basic_info_event.dart';
import 'basic_info_state.dart';

class BasicInfoBloc extends Bloc<BasicInfoEvent, BasicInfoState> {
  BasicInfoBloc({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const BasicInfoLoading()) {
    on<BasicInfoStarted>(_onStarted);
    on<BasicInfoEventNameChanged>(_onEventNameChanged);
    on<BasicInfoEditTransPressed>(_onEditTransPressed);
    on<BasicInfoTransSelected>(_onTransSelected);
    on<BasicInfoEditMembersPressed>(_onEditMembersPressed);
    on<BasicInfoMembersSelected>(_onMembersSelected);
    on<BasicInfoEditTagsPressed>(_onEditTagsPressed);
    on<BasicInfoTagsSelected>(_onTagsSelected);
    on<BasicInfoEditPayMemberPressed>(_onEditPayMemberPressed);
    on<BasicInfoPayMemberSelected>(_onPayMemberSelected);
    on<BasicInfoKmPerGasChanged>(_onKmPerGasChanged);
    on<BasicInfoPricePerGasChanged>(_onPricePerGasChanged);
  }

  final EventRepository _eventRepository;

  Future<void> _onStarted(
    BasicInfoStarted event,
    Emitter<BasicInfoState> emit,
  ) async {
    emit(const BasicInfoLoading());
    try {
      final domain = await _eventRepository.fetch(event.eventId);
      final draft = BasicInfoDraft(
        eventName: domain.eventName,
        selectedTrans: domain.trans,
        selectedMembers: domain.members,
        selectedTags: domain.tags,
        selectedPayMember: domain.payMember,
        kmPerGasInput: domain.kmPerGas != null
            ? (domain.kmPerGas! / 10.0).toString()
            : '',
        pricePerGasInput: domain.pricePerGas?.toString() ?? '',
      );
      emit(BasicInfoLoaded(draft: draft));
    } on Exception catch (e) {
      emit(BasicInfoError(message: e.toString()));
    }
  }

  Future<void> _onEventNameChanged(
    BasicInfoEventNameChanged event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(eventName: event.name),
      ));
    }
  }

  Future<void> _onEditTransPressed(
    BasicInfoEditTransPressed event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        delegate: const BasicInfoOpenTransSelectionDelegate(),
      ));
    }
  }

  Future<void> _onTransSelected(
    BasicInfoTransSelected event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedTrans: event.trans),
      ));
    }
  }

  Future<void> _onEditMembersPressed(
    BasicInfoEditMembersPressed event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        delegate: const BasicInfoOpenMembersSelectionDelegate(),
      ));
    }
  }

  Future<void> _onMembersSelected(
    BasicInfoMembersSelected event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedMembers: event.members),
      ));
    }
  }

  Future<void> _onEditTagsPressed(
    BasicInfoEditTagsPressed event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        delegate: const BasicInfoOpenTagsSelectionDelegate(),
      ));
    }
  }

  Future<void> _onTagsSelected(
    BasicInfoTagsSelected event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedTags: event.tags),
      ));
    }
  }

  Future<void> _onEditPayMemberPressed(
    BasicInfoEditPayMemberPressed event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        delegate: const BasicInfoOpenPayMemberSelectionDelegate(),
      ));
    }
  }

  Future<void> _onPayMemberSelected(
    BasicInfoPayMemberSelected event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedPayMember: event.payMember),
      ));
    }
  }

  Future<void> _onKmPerGasChanged(
    BasicInfoKmPerGasChanged event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(kmPerGasInput: event.input),
      ));
    }
  }

  Future<void> _onPricePerGasChanged(
    BasicInfoPricePerGasChanged event,
    Emitter<BasicInfoState> emit,
  ) async {
    if (state is BasicInfoLoaded) {
      final current = state as BasicInfoLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(pricePerGasInput: event.input),
      ));
    }
  }
}
