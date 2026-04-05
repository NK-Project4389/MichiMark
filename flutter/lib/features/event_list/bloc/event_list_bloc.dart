import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../adapter/event_list_adapter.dart';
import '../../../repository/event_repository.dart';
import 'event_list_event.dart';
import 'event_list_state.dart';

class EventListBloc extends Bloc<EventListEvent, EventListState> {
  EventListBloc({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const EventListLoading()) {
    on<EventListStarted>(_onStarted);
    on<EventListItemTapped>(_onItemTapped);
    on<EventListAddButtonPressed>(_onAddButtonPressed);
    on<EventListSettingsButtonPressed>(_onSettingsButtonPressed);
    on<EventListDeleteRequested>(_onDeleteRequested);
    on<EventListTopicSelectedForNewEvent>(_onTopicSelectedForNewEvent);
  }

  final EventRepository _eventRepository;

  Future<void> _onStarted(
    EventListStarted event,
    Emitter<EventListState> emit,
  ) async {
    emit(const EventListLoading());
    try {
      final events = await _eventRepository.fetchAll();
      final projection = EventListAdapter.toProjection(events);
      emit(EventListLoaded(projection: projection));
    } on Exception catch (e) {
      emit(EventListError(message: e.toString()));
    }
  }

  Future<void> _onItemTapped(
    EventListItemTapped event,
    Emitter<EventListState> emit,
  ) async {
    if (state is EventListLoaded) {
      final current = state as EventListLoaded;
      emit(current.copyWith(
        delegate: OpenEventDetailDelegate(event.eventId),
      ));
    }
  }

  Future<void> _onAddButtonPressed(
    EventListAddButtonPressed event,
    Emitter<EventListState> emit,
  ) async {
    if (state is EventListLoaded) {
      final current = state as EventListLoaded;
      emit(current.copyWith(showTopicSelection: true));
    }
  }

  Future<void> _onSettingsButtonPressed(
    EventListSettingsButtonPressed event,
    Emitter<EventListState> emit,
  ) async {
    if (state is EventListLoaded) {
      final current = state as EventListLoaded;
      emit(current.copyWith(delegate: const OpenSettingsDelegate()));
    }
  }

  Future<void> _onDeleteRequested(
    EventListDeleteRequested event,
    Emitter<EventListState> emit,
  ) async {
    try {
      await _eventRepository.delete(event.eventId);
      final events = await _eventRepository.fetchAll();
      final projection = EventListAdapter.toProjection(events);
      emit(EventListLoaded(projection: projection));
    } on Exception catch (e) {
      emit(EventListError(message: e.toString()));
    }
  }

  Future<void> _onTopicSelectedForNewEvent(
    EventListTopicSelectedForNewEvent event,
    Emitter<EventListState> emit,
  ) async {
    if (state is EventListLoaded) {
      final current = state as EventListLoaded;
      emit(current.copyWith(
        delegate: OpenAddEventWithTopicDelegate(
          topicType: event.topicType,
          eventId: event.eventId,
        ),
      ));
    }
  }
}
