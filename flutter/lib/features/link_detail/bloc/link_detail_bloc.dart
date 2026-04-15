import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../adapter/payment_section_projection_adapter.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/transaction/mark_link/mark_link_domain.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../repository/event_repository.dart';
import '../draft/link_detail_draft.dart';
import 'link_detail_event.dart';
import 'link_detail_state.dart';

class LinkDetailBloc extends Bloc<LinkDetailEvent, LinkDetailState> {
  LinkDetailBloc({
    required EventRepository eventRepository,
    this.insertAfterSeq,
  })  : _eventRepository = eventRepository,
        super(const LinkDetailLoading()) {
    on<LinkDetailStarted>(_onStarted);
    on<LinkDetailDismissPressed>(_onDismissPressed);
    on<LinkDetailNameChanged>(_onNameChanged);
    on<LinkDetailDistanceChanged>(_onDistanceChanged);
    on<LinkDetailMemberChipToggled>(_onMemberChipToggled);
    on<LinkDetailEditActionsPressed>(_onEditActionsPressed);
    on<LinkDetailActionsSelected>(_onActionsSelected);
    on<LinkDetailMemoChanged>(_onMemoChanged);
    on<LinkDetailSaveTapped>(_onSaveTapped);
    on<LinkDetailIsFuelToggled>(_onIsFuelToggled);
    on<LinkDetailFuelFieldsChanged>(_onFuelFieldsChanged);
    on<LinkDetailTopicConfigUpdated>(_onTopicConfigUpdated);
    on<LinkDetailGasPayerChipToggled>(_onGasPayerChipToggled);
    on<LinkDetailMembersAllSelected>(_onMembersAllSelected);
    on<LinkDetailMembersAllCleared>(_onMembersAllCleared);
    on<LinkDetailCancelDiscardConfirmed>(_onCancelDiscardConfirmed);
    on<LinkDetailCancelDialogDismissed>(_onCancelDialogDismissed);
    on<LinkDetailPaymentPlusTapped>(_onPaymentPlusTapped);
    on<LinkDetailPaymentTapped>(_onPaymentTapped);
    on<LinkDetailPaymentsUpdated>(_onPaymentsUpdated);
    on<LinkDetailPaymentsReloadRequested>(_onPaymentsReloadRequested);
  }

  final EventRepository _eventRepository;

  /// null = 末尾追加（現行動作）、non-null = 指定位置に挿入
  final int? insertAfterSeq;

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
          initialDraft: draft,
          topicConfig: event.topicConfig,
          availableMembers: event.eventMembers,
          eventId: _eventId,
        ));
        return;
      }
      // 既存編集モード
      // 後から非表示になったマスタ項目を除外する（B-10修正）
      final visibleEventMembers =
          event.eventMembers.where((m) => m.isVisible).toSet();
      final filteredMembers = markLink.members
          .where((m) => visibleEventMembers.any((vm) => vm.id == m.id))
          .toList();
      final filteredActions =
          markLink.actions.where((a) => a.isVisible).toList();
      final draft = LinkDetailDraft(
        markLinkName: markLink.markLinkName ?? '',
        markLinkDate: markLink.markLinkDate,
        distanceValueInput: markLink.distanceValue?.toString() ?? '',
        selectedMembers: filteredMembers,
        selectedActions: filteredActions,
        memo: markLink.memo ?? '',
        isFuel: markLink.isFuel,
        pricePerGasInput: markLink.pricePerGas?.toString() ?? '',
        gasQuantityInput: markLink.gasQuantity != null
            ? (markLink.gasQuantity! / 10).toStringAsFixed(1)
            : '',
        gasPriceInput: markLink.gasPrice?.toString() ?? '',
        selectedGasPayer: markLink.gasPayer,
      );
      final paymentSection = PaymentSectionProjectionAdapter.toProjection(
        allPayments: domain.payments,
        markLinkId: _markLinkId,
      );
      emit(LinkDetailLoaded(
        draft: draft,
        initialDraft: draft,
        topicConfig: event.topicConfig,
        availableMembers: event.eventMembers,
        paymentSection: paymentSection,
        eventId: _eventId,
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
      if (current.draft == current.initialDraft) {
        // 差分なし: そのまま Dismiss
        emit(current.copyWith(delegate: const LinkDetailDismissDelegate()));
      } else {
        // 差分あり: 確認ダイアログを表示
        emit(current.copyWith(showCancelConfirmDialog: true));
      }
    }
  }

  Future<void> _onCancelDiscardConfirmed(
    LinkDetailCancelDiscardConfirmed event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        draft: current.initialDraft,
        showCancelConfirmDialog: false,
        delegate: const LinkDetailDismissDelegate(),
      ));
    }
  }

  Future<void> _onCancelDialogDismissed(
    LinkDetailCancelDialogDismissed event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(showCancelConfirmDialog: false));
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

  Future<void> _onMemberChipToggled(
    LinkDetailMemberChipToggled event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      final selectedMembers = List<MemberDomain>.from(current.draft.selectedMembers);
      final alreadySelected = selectedMembers.any((m) => m.id == event.member.id);
      if (alreadySelected) {
        selectedMembers.removeWhere((m) => m.id == event.member.id);
      } else {
        selectedMembers.add(event.member);
      }
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedMembers: selectedMembers),
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
        List<MarkLinkDomain> shiftedMarkLinks = List.of(existing.markLinks);
        if (existingMarkLink != null) {
          seq = existingMarkLink.markLinkSeq;
        } else {
          final insertSeq = insertAfterSeq;
          if (insertSeq != null) {
            // 挿入モード: insertAfterSeq より大きい seq を全て +1
            shiftedMarkLinks = shiftedMarkLinks.map((ml) {
              if (!ml.isDeleted && ml.markLinkSeq > insertSeq) {
                return ml.copyWith(markLinkSeq: ml.markLinkSeq + 1);
              }
              return ml;
            }).toList();
            seq = insertSeq + 1;
          } else {
            seq = activeMarkLinks.isEmpty
                ? 0
                : activeMarkLinks.map((ml) => ml.markLinkSeq).reduce((a, b) => a > b ? a : b) + 1;
          }
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
          gasPayer: draft.selectedGasPayer,
          createdAt: existingMarkLink?.createdAt ?? now,
          updatedAt: now,
        );

        final updatedMarkLinks = List<MarkLinkDomain>.from(
          shiftedMarkLinks.where((ml) => ml.id != _markLinkId),
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

  Future<void> _onGasPayerChipToggled(
    LinkDetailGasPayerChipToggled event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      final isSameMember = current.draft.selectedGasPayer?.id == event.member.id;
      final newGasPayer = isSameMember ? null : event.member;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedGasPayer: newGasPayer),
      ));
    }
  }

  Future<void> _onMembersAllSelected(
    LinkDetailMembersAllSelected event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedMembers: current.availableMembers),
      ));
    }
  }

  Future<void> _onMembersAllCleared(
    LinkDetailMembersAllCleared event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedMembers: const []),
      ));
    }
  }

  Future<void> _onPaymentPlusTapped(
    LinkDetailPaymentPlusTapped event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        delegate: LinkDetailOpenPaymentNewDelegate(_markLinkId),
      ));
    }
  }

  Future<void> _onPaymentTapped(
    LinkDetailPaymentTapped event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      emit(current.copyWith(
        delegate: LinkDetailOpenPaymentByIdDelegate(event.paymentId),
      ));
    }
  }

  Future<void> _onPaymentsUpdated(
    LinkDetailPaymentsUpdated event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is LinkDetailLoaded) {
      final current = state as LinkDetailLoaded;
      final paymentSection = PaymentSectionProjectionAdapter.toProjection(
        allPayments: event.allPayments,
        markLinkId: _markLinkId,
      );
      emit(current.copyWith(paymentSection: paymentSection));
    }
  }

  Future<void> _onPaymentsReloadRequested(
    LinkDetailPaymentsReloadRequested event,
    Emitter<LinkDetailState> emit,
  ) async {
    if (state is! LinkDetailLoaded) return;
    final current = state as LinkDetailLoaded;
    try {
      final domain = await _eventRepository.fetch(_eventId);
      final paymentSection = PaymentSectionProjectionAdapter.toProjection(
        allPayments: domain.payments,
        markLinkId: _markLinkId,
      );
      emit(current.copyWith(paymentSection: paymentSection));
    } on Exception {
      // リロード失敗は無視（現在の状態を維持）
    }
  }
}
