import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../adapter/event_detail_adapter.dart';
import '../../../adapter/mark_link_draft_adapter.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../features/event_detail/projection/michi_info_list_projection.dart';
import '../../../features/link_detail/draft/link_detail_draft.dart';
import '../../../features/mark_detail/draft/mark_detail_draft.dart';
import '../../../features/shared/projection/mark_link_item_projection.dart';
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
    on<MichiInfoMarkDraftApplied>(_onMarkDraftApplied);
    on<MichiInfoLinkDraftApplied>(_onLinkDraftApplied);
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

  Future<void> _onMarkDraftApplied(
    MichiInfoMarkDraftApplied event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (state case MichiInfoLoaded current) {
      final updated = _applyMarkDraft(
        current.projection,
        event.markLinkId,
        event.draft,
      );
      emit(current.copyWith(projection: updated));
    }
  }

  Future<void> _onLinkDraftApplied(
    MichiInfoLinkDraftApplied event,
    Emitter<MichiInfoState> emit,
  ) async {
    if (state case MichiInfoLoaded current) {
      final updated = _applyLinkDraft(
        current.projection,
        event.markLinkId,
        event.draft,
      );
      emit(current.copyWith(projection: updated));
    }
  }

  MichiInfoListProjection _applyMarkDraft(
    MichiInfoListProjection base,
    String markLinkId,
    MarkDetailDraft draft,
  ) {
    final items = List<MarkLinkItemProjection>.from(base.items);
    final existingIndex = items.indexWhere((item) => item.id == markLinkId);
    final seq = existingIndex >= 0
        ? items[existingIndex].markLinkSeq
        : (items.isEmpty ? 0 : items.map((i) => i.markLinkSeq).reduce((a, b) => a > b ? a : b) + 1);
    final newItem = MarkLinkDraftAdapter.fromMarkDraft(
      markLinkId: markLinkId,
      markLinkSeq: seq,
      draft: draft,
    );
    if (existingIndex >= 0) {
      items[existingIndex] = newItem;
    } else {
      items.add(newItem);
    }
    items.sort((a, b) => a.markLinkSeq.compareTo(b.markLinkSeq));
    return MichiInfoListProjection(items: items);
  }

  MichiInfoListProjection _applyLinkDraft(
    MichiInfoListProjection base,
    String markLinkId,
    LinkDetailDraft draft,
  ) {
    final items = List<MarkLinkItemProjection>.from(base.items);
    final existingIndex = items.indexWhere((item) => item.id == markLinkId);
    final seq = existingIndex >= 0
        ? items[existingIndex].markLinkSeq
        : (items.isEmpty ? 0 : items.map((i) => i.markLinkSeq).reduce((a, b) => a > b ? a : b) + 1);
    final newItem = MarkLinkDraftAdapter.fromLinkDraft(
      markLinkId: markLinkId,
      markLinkSeq: seq,
      draft: draft,
    );
    if (existingIndex >= 0) {
      items[existingIndex] = newItem;
    } else {
      items.add(newItem);
    }
    items.sort((a, b) => a.markLinkSeq.compareTo(b.markLinkSeq));
    return MichiInfoListProjection(items: items);
  }
}
