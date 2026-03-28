import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/event_repository.dart';
import '../draft/link_detail_draft.dart';
import 'link_detail_event.dart';
import 'link_detail_state.dart';

class LinkDetailBloc extends Bloc<LinkDetailEvent, LinkDetailState> {
  LinkDetailBloc({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const LinkDetailLoading()) {
    on<LinkDetailStarted>(_onStarted);
    on<LinkDetailDismissPressed>(_onDismissPressed);
    on<LinkDetailNameChanged>(_onNameChanged);
    on<LinkDetailDistanceChanged>(_onDistanceChanged);
    on<LinkDetailEditMembersPressed>(_onEditMembersPressed);
    on<LinkDetailMembersSelected>(_onMembersSelected);
    on<LinkDetailEditActionsPressed>(_onEditActionsPressed);
    on<LinkDetailActionsSelected>(_onActionsSelected);
    on<LinkDetailMemoChanged>(_onMemoChanged);
  }

  final EventRepository _eventRepository;

  Future<void> _onStarted(
    LinkDetailStarted event,
    Emitter<LinkDetailState> emit,
  ) async {
    emit(const LinkDetailLoading());
    try {
      final domain = await _eventRepository.fetch(event.eventId);
      final markLink = domain.markLinks
          .where((ml) => ml.id == event.markLinkId && !ml.isDeleted)
          .firstOrNull;
      if (markLink == null) {
        emit(const LinkDetailError(message: 'リンクが見つかりません'));
        return;
      }
      final draft = LinkDetailDraft(
        markLinkName: markLink.markLinkName ?? '',
        markLinkDate: markLink.markLinkDate,
        distanceValueInput: markLink.distanceValue?.toString() ?? '',
        selectedMembers: markLink.members,
        selectedActions: markLink.actions,
        memo: markLink.memo ?? '',
      );
      emit(LinkDetailLoaded(draft: draft));
    } on Exception catch (e) {
      emit(LinkDetailError(message: e.toString()));
    }
  }

  Future<void> _onDismissPressed(
    LinkDetailDismissPressed event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(delegate: const LinkDetailDismissDelegate()));
    }
  }

  Future<void> _onNameChanged(
    LinkDetailNameChanged event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(markLinkName: event.name),
      ));
    }
  }

  Future<void> _onDistanceChanged(
    LinkDetailDistanceChanged event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(distanceValueInput: event.input),
      ));
    }
  }

  Future<void> _onEditMembersPressed(
    LinkDetailEditMembersPressed event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        delegate: const LinkDetailOpenMembersSelectionDelegate(),
      ));
    }
  }

  Future<void> _onMembersSelected(
    LinkDetailMembersSelected event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedMembers: event.members),
      ));
    }
  }

  Future<void> _onEditActionsPressed(
    LinkDetailEditActionsPressed event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        delegate: const LinkDetailOpenActionsSelectionDelegate(),
      ));
    }
  }

  Future<void> _onActionsSelected(
    LinkDetailActionsSelected event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedActions: event.actions),
      ));
    }
  }

  Future<void> _onMemoChanged(
    LinkDetailMemoChanged event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(memo: event.memo),
      ));
    }
  }
}
