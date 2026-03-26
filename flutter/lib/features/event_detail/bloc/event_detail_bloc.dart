import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../adapter/event_detail_adapter.dart';
import '../../../repository/event_repository.dart';
import '../draft/event_detail_draft.dart';
import 'event_detail_event.dart';
import 'event_detail_state.dart';

class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  EventDetailBloc({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const EventDetailLoading()) {
    on<EventDetailStarted>(_onStarted);
    on<EventDetailTabSelected>(_onTabSelected);
    on<EventDetailDismissPressed>(_onDismissPressed);
    on<EventDetailOpenMarkRequested>(_onOpenMarkRequested);
    on<EventDetailOpenLinkRequested>(_onOpenLinkRequested);
    on<EventDetailOpenPaymentRequested>(_onOpenPaymentRequested);
    on<EventDetailAddMarkLinkRequested>(_onAddMarkLinkRequested);
  }

  final EventRepository _eventRepository;

  Future<void> _onStarted(
    EventDetailStarted event,
    Emitter<EventDetailState> emit,
  ) async {
    emit(const EventDetailLoading());
    try {
      final domain = await _eventRepository.fetch(event.eventId);
      final projection = EventDetailAdapter.toProjection(domain);
      emit(EventDetailLoaded(
        projection: projection,
        draft: const EventDetailDraft(),
      ));
    } on Exception catch (e) {
      emit(EventDetailError(message: e.toString()));
    }
  }

  Future<void> _onTabSelected(
    EventDetailTabSelected event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state is EventDetailLoaded) {
      final current = state as EventDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedTab: event.tab),
      ));
    }
  }

  Future<void> _onDismissPressed(
    EventDetailDismissPressed event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state is EventDetailLoaded) {
      final current = state as EventDetailLoaded;
      emit(current.copyWith(delegate: const EventDetailDismissDelegate()));
    }
  }

  Future<void> _onOpenMarkRequested(
    EventDetailOpenMarkRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state is EventDetailLoaded) {
      final current = state as EventDetailLoaded;
      emit(current.copyWith(
        delegate: EventDetailOpenMarkDelegate(event.markLinkId),
      ));
    }
  }

  Future<void> _onOpenLinkRequested(
    EventDetailOpenLinkRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state is EventDetailLoaded) {
      final current = state as EventDetailLoaded;
      emit(current.copyWith(
        delegate: EventDetailOpenLinkDelegate(event.markLinkId),
      ));
    }
  }

  Future<void> _onOpenPaymentRequested(
    EventDetailOpenPaymentRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state is EventDetailLoaded) {
      final current = state as EventDetailLoaded;
      emit(current.copyWith(
        delegate: EventDetailOpenPaymentDelegate(event.paymentId),
      ));
    }
  }

  Future<void> _onAddMarkLinkRequested(
    EventDetailAddMarkLinkRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state is EventDetailLoaded) {
      final current = state as EventDetailLoaded;
      emit(current.copyWith(
        delegate: const EventDetailAddMarkLinkDelegate(),
      ));
    }
  }
}
