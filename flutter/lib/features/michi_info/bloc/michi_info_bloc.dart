import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../adapter/event_detail_adapter.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../repository/event_repository.dart';
import '../draft/michi_info_draft.dart';
import 'michi_info_event.dart';
import 'michi_info_state.dart';

class MichiInfoBloc extends Bloc<MichiInfoEvent, MichiInfoState> {
  MichiInfoBloc({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const MichiInfoLoading()) {
    on<MichiInfoStarted>(_onStarted);
    on<MichiInfoItemTapped>(_onItemTapped);
    on<MichiInfoAddMarkPressed>(_onAddMarkPressed);
    on<MichiInfoAddLinkPressed>(_onAddLinkPressed);
  }

  final EventRepository _eventRepository;
  String _eventId = '';

  Future<void> _onStarted(
    MichiInfoStarted event,
    Emitter<MichiInfoState> emit,
  ) async {
    _eventId = event.eventId;
    emit(const MichiInfoLoading());
    try {
      final domain = await _eventRepository.fetch(event.eventId);
      final projection = EventDetailAdapter.toProjection(domain).michiInfo;
      emit(MichiInfoLoaded(
        projection: projection,
        draft: const MichiInfoDraft(),
      ));
    } on Exception catch (e) {
      emit(MichiInfoError(message: e.toString()));
    }
  }

  Future<void> _onItemTapped(
    MichiInfoItemTapped event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (state is MichiInfoLoaded) {
      final current = state as MichiInfoLoaded;
      final delegate = switch (event.type) {
        MarkOrLink.mark => MichiInfoOpenMarkDelegate(
            eventId: _eventId,
            markLinkId: event.markLinkId,
          ),
        MarkOrLink.link => MichiInfoOpenLinkDelegate(
            eventId: _eventId,
            markLinkId: event.markLinkId,
          ),
      };
      emit(current.copyWith(delegate: delegate));
    }
  }

  Future<void> _onAddMarkPressed(
    MichiInfoAddMarkPressed event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (state is MichiInfoLoaded) {
      final current = state as MichiInfoLoaded;
      emit(current.copyWith(delegate: MichiInfoAddMarkDelegate(_eventId)));
    }
  }

  Future<void> _onAddLinkPressed(
    MichiInfoAddLinkPressed event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (state is MichiInfoLoaded) {
      final current = state as MichiInfoLoaded;
      emit(current.copyWith(delegate: MichiInfoAddLinkDelegate(_eventId)));
    }
  }
}
