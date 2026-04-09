import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/transaction/mark_link/mark_link_domain.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
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
    on<LinkDetailSaveTapped>(_onSaveTapped);
    on<LinkDetailIsFuelToggled>(_onIsFuelToggled);
    on<LinkDetailFuelFieldsChanged>(_onFuelFieldsChanged);
    on<LinkDetailTopicConfigUpdated>(_onTopicConfigUpdated);
  }

  final EventRepository _eventRepository;
  String _eventId = '';
  String _markLinkId = '';

  Future<void> _onStarted(
    LinkDetailStarted event,
    Emitter<LinkDetailState> emit,
  ) async {
    _eventId = event.eventId;
    _markLinkId = event.markLinkId;
    emit(const LinkDetailLoading());
    try {
      final domain = await _eventRepository.fetch(event.eventId);
      final markLink = domain.markLinks
          .where((ml) => ml.id == event.markLinkId && !ml.isDeleted)
          .firstOrNull;
      if (markLink == null) {
        // markLinksに存在しない: 新規作成モード（UUIDはrouterから渡された値）
        final draft = LinkDetailDraft(markLinkDate: DateTime.now());
        emit(LinkDetailLoaded(
          draft: draft,
          topicConfig: event.topicConfig,
          availableMembers: event.eventMembers,
        ));
        return;
      }
      // 既存編集モード
      final draft = LinkDetailDraft(
        markLinkName: markLink.markLinkName ?? '',
        markLinkDate: markLink.markLinkDate,
        distanceValueInput: markLink.distanceValue?.toString() ?? '',
        selectedMembers: markLink.members,
        selectedActions: markLink.actions,
        memo: markLink.memo ?? '',
        isFuel: markLink.isFuel,
        pricePerGasInput: markLink.pricePerGas?.toString() ?? '',
        gasQuantityInput: markLink.gasQuantity != null
            ? (markLink.gasQuantity! / 10).toStringAsFixed(1)
            : '',
        gasPriceInput: markLink.gasPrice?.toString() ?? '',
      );
      emit(LinkDetailLoaded(
        draft: draft,
        topicConfig: event.topicConfig,
        availableMembers: event.eventMembers,
      ));
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

  Future<void> _onSaveTapped(
    LinkDetailSaveTapped event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state case LinkDetailLoaded current) {
      emit(current.copyWith(isSaving: true));
      try {
        final existing = await _eventRepository.fetch(_eventId);
        final draft = current.draft;

        // markLinkSeq の算出
        final activeMarkLinks = existing.markLinks.where((ml) => !ml.isDeleted).toList();
        final existingMarkLink = activeMarkLinks.where((ml) => ml.id == _markLinkId).firstOrNull;
        final int seq;
        if (existingMarkLink != null) {
          seq = existingMarkLink.markLinkSeq;
        } else {
          seq = activeMarkLinks.isEmpty
              ? 0
              : activeMarkLinks.map((ml) => ml.markLinkSeq).reduce((a, b) => a > b ? a : b) + 1;
        }

        final distanceValue = draft.distanceValueInput.isEmpty
            ? null
            : int.tryParse(draft.distanceValueInput.replaceAll(',', ''));

        final pricePerGas = draft.pricePerGasInput.isEmpty
            ? null
            : int.tryParse(draft.pricePerGasInput.replaceAll(',', ''));

        final gasQuantity = draft.gasQuantityInput.isEmpty
            ? null
            : (double.tryParse(draft.gasQuantityInput) != null
                ? (double.parse(draft.gasQuantityInput) * 10).round()
                : null);

        final gasPrice = draft.gasPriceInput.isEmpty
            ? null
            : int.tryParse(draft.gasPriceInput.replaceAll(',', ''));

        final now = DateTime.now();
        final newMarkLink = MarkLinkDomain(
          id: _markLinkId,
          markLinkSeq: seq,
          markLinkType: MarkOrLink.link,
          markLinkDate: draft.markLinkDate,
          markLinkName: draft.markLinkName.isEmpty ? null : draft.markLinkName,
          members: draft.selectedMembers,
          distanceValue: distanceValue,
          actions: draft.selectedActions,
          memo: draft.memo.isEmpty ? null : draft.memo,
          isFuel: draft.isFuel,
          pricePerGas: pricePerGas,
          gasQuantity: gasQuantity,
          gasPrice: gasPrice,
          createdAt: existingMarkLink?.createdAt ?? now,
          updatedAt: now,
        );

        final updatedMarkLinks = List<MarkLinkDomain>.from(
          existing.markLinks.where((ml) => ml.id != _markLinkId),
        )..add(newMarkLink);

        final updated = existing.copyWith(
          markLinks: updatedMarkLinks,
          updatedAt: now,
        );
        await _eventRepository.save(updated);

        emit(current.copyWith(
          isSaving: false,
          delegate: LinkDetailSavedDelegate(markLinkId: _markLinkId, draft: draft),
        ));
      } on Exception catch (e) {
        if (state case LinkDetailLoaded loaded) {
          emit(loaded.copyWith(
            isSaving: false,
            delegate: LinkDetailSaveErrorDelegate(e.toString()),
          ));
        }
      }
    }
  }

  Future<void> _onIsFuelToggled(
    LinkDetailIsFuelToggled event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(isFuel: !current.draft.isFuel),
      ));
    }
  }

  Future<void> _onFuelFieldsChanged(
    LinkDetailFuelFieldsChanged event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(
          pricePerGasInput: event.pricePerGas,
          gasQuantityInput: event.gasQuantity,
          gasPriceInput: event.gasPrice,
        ),
      ));
    }
  }

  Future<void> _onTopicConfigUpdated(
    LinkDetailTopicConfigUpdated event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(topicConfig: event.config));
    }
  }
}
