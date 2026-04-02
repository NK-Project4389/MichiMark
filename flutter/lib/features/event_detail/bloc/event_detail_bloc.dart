import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../adapter/event_detail_adapter.dart';
import '../../../domain/transaction/event/event_domain.dart';
import '../../../repository/event_repository.dart';
import '../../../repository/repository_error.dart';
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
    on<EventDetailSaveRequested>(_onSaveRequested);
  }

  final EventRepository _eventRepository;

  Future<void> _onStarted(
    EventDetailStarted event,
    Emitter<EventDetailState> emit,
  ) async {
    emit(const EventDetailLoading());
    try {
      final EventDomain domain;
      try {
        domain = await _eventRepository.fetch(event.eventId);
      } on NotFoundError {
        // 新規作成モード: 空ドメインを生成してRepositoryに保存
        final now = DateTime.now();
        final newDomain = EventDomain(
          id: event.eventId,
          eventName: '',
          createdAt: now,
          updatedAt: now,
        );
        await _eventRepository.save(newDomain);
        final projection = EventDetailAdapter.toProjection(newDomain);
        emit(EventDetailLoaded(
          projection: projection,
          draft: const EventDetailDraft(),
        ));
        return;
      }
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
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedTab: event.tab),
      ));
    }
  }

  Future<void> _onDismissPressed(
    EventDetailDismissPressed event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(delegate: const EventDetailDismissDelegate()));
    }
  }

  Future<void> _onOpenMarkRequested(
    EventDetailOpenMarkRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(
        delegate: EventDetailOpenMarkDelegate(event.markLinkId),
      ));
    }
  }

  Future<void> _onOpenLinkRequested(
    EventDetailOpenLinkRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(
        delegate: EventDetailOpenLinkDelegate(event.markLinkId),
      ));
    }
  }

  Future<void> _onOpenPaymentRequested(
    EventDetailOpenPaymentRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(
        delegate: EventDetailOpenPaymentDelegate(event.paymentId),
      ));
    }
  }

  Future<void> _onAddMarkLinkRequested(
    EventDetailAddMarkLinkRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state case final EventDetailLoaded current) {
      emit(current.copyWith(
        delegate: const EventDetailAddMarkLinkDelegate(),
      ));
    }
  }

  Future<void> _onSaveRequested(
    EventDetailSaveRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state is! EventDetailLoaded) return;
    final current = state as EventDetailLoaded;

    emit(current.copyWith(isSaving: true));

    try {
      final existing = await _eventRepository.fetch(event.eventId);
      final draft = event.basicInfoDraft;

      final kmPerGas = draft.kmPerGasInput.isEmpty
          ? null
          : (double.tryParse(draft.kmPerGasInput) != null
              ? (double.parse(draft.kmPerGasInput) * 10).round()
              : null);

      final pricePerGas = draft.pricePerGasInput.isEmpty
          ? null
          : int.tryParse(draft.pricePerGasInput);

      final updated = EventDomain(
        id: existing.id,
        eventName: draft.eventName,
        trans: draft.selectedTrans,
        members: draft.selectedMembers,
        tags: draft.selectedTags,
        kmPerGas: kmPerGas,
        pricePerGas: pricePerGas,
        payMember: draft.selectedPayMember,
        markLinks: existing.markLinks,
        payments: existing.payments,
        isDeleted: existing.isDeleted,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      await _eventRepository.save(updated);

      final projection = EventDetailAdapter.toProjection(updated);
      emit(EventDetailLoaded(
        projection: projection,
        draft: current.draft,
        delegate: const EventDetailSavedDelegate(),
        isSaving: false,
      ));
    } on Exception catch (e) {
      emit(current.copyWith(
        isSaving: false,
        saveErrorMessage: e.toString(),
      ));
    }
  }
}
