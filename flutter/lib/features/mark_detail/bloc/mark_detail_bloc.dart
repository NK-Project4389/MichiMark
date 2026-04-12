import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/transaction/mark_link/mark_link_domain.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../repository/event_repository.dart';
import '../../../repository/trans_repository.dart';
import '../draft/mark_detail_draft.dart';
import 'mark_detail_event.dart';
import 'mark_detail_state.dart';

class MarkDetailBloc extends Bloc<MarkDetailEvent, MarkDetailState> {
  MarkDetailBloc({
    required EventRepository eventRepository,
    required TransRepository transRepository,
    this.insertAfterSeq,
  })  : _eventRepository = eventRepository,
        _transRepository = transRepository,
        super(const MarkDetailLoading()) {
    on<MarkDetailStarted>(_onStarted);
    on<MarkDetailDismissPressed>(_onDismissPressed);
    on<MarkDetailNameChanged>(_onNameChanged);
    on<MarkDetailDateChanged>(_onDateChanged);
    on<MarkDetailMemberChipToggled>(_onMemberChipToggled);
    on<MarkDetailMeterValueChanged>(_onMeterValueChanged);
    on<MarkDetailEditActionsPressed>(_onEditActionsPressed);
    on<MarkDetailActionsSelected>(_onActionsSelected);
    on<MarkDetailMemoChanged>(_onMemoChanged);
    on<MarkDetailSaveTapped>(_onSaveTapped);
    on<MarkDetailIsFuelToggled>(_onIsFuelToggled);
    on<MarkDetailFuelFieldsChanged>(_onFuelFieldsChanged);
    on<MarkDetailTopicConfigUpdated>(_onTopicConfigUpdated);
    on<MarkDetailGasPayerChipToggled>(_onGasPayerChipToggled);
  }

  final EventRepository _eventRepository;
  final TransRepository _transRepository;

  /// null = 末尾追加（現行動作）、non-null = 指定位置に挿入
  final int? insertAfterSeq;

  String _eventId = '';
  String _markLinkId = '';

  Future<void> _onStarted(
    MarkDetailStarted event,
    Emitter<MarkDetailState> emit,
  ) async {
    _eventId = event.eventId;
    _markLinkId = event.markLinkId;
    emit(const MarkDetailLoading());
    try {
      final domain = await _eventRepository.fetch(event.eventId);
      final markLink = domain.markLinks
          .where((ml) => ml.id == event.markLinkId && !ml.isDeleted)
          .firstOrNull;
      if (markLink == null) {
        // markLinksに存在しない: 新規作成モード（UUIDはrouterから渡された値）
        final draft = MarkDetailDraft(
          markLinkDate: event.initialMarkLinkDate ?? DateTime.now(),
          meterValueInput: event.initialMeterValueInput,
          selectedMembers: event.initialSelectedMembers,
        );
        emit(MarkDetailLoaded(
          draft: draft,
          topicConfig: event.topicConfig,
          availableMembers: event.eventMembers,
        ));
        return;
      }
      // 既存編集モード
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
        selectedGasPayer: markLink.gasPayer,
      );
      emit(MarkDetailLoaded(
        draft: draft,
        topicConfig: event.topicConfig,
        availableMembers: event.eventMembers,
      ));
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

  Future<void> _onMemberChipToggled(
    MarkDetailMemberChipToggled event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
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

  Future<void> _onSaveTapped(
    MarkDetailSaveTapped event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state case MarkDetailLoaded current) {
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

        final meterValue = draft.meterValueInput.isEmpty
            ? null
            : int.tryParse(draft.meterValueInput.replaceAll(',', ''));

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
          markLinkType: MarkOrLink.mark,
          markLinkDate: draft.markLinkDate,
          markLinkName: draft.markLinkName.isEmpty ? null : draft.markLinkName,
          members: draft.selectedMembers,
          meterValue: meterValue,
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

        // REQ-MAD-005: 保存したメーター値がTrans側より大きければTransを更新する
        if (meterValue != null) {
          final trans = existing.trans;
          if (trans != null) {
            final currentMax = trans.meterValue ?? 0;
            if (meterValue > currentMax) {
              await _transRepository.save(
                trans.copyWith(meterValue: meterValue, updatedAt: now),
              );
            }
          }
        }

        emit(current.copyWith(
          isSaving: false,
          delegate: MarkDetailSavedDelegate(markLinkId: _markLinkId, draft: draft),
        ));
      } on Exception catch (e) {
        if (state case MarkDetailLoaded loaded) {
          emit(loaded.copyWith(
            isSaving: false,
            delegate: MarkDetailSaveErrorDelegate(e.toString()),
          ));
        }
      }
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

  Future<void> _onTopicConfigUpdated(
    MarkDetailTopicConfigUpdated event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      emit(current.copyWith(topicConfig: event.config));
    }
  }

  Future<void> _onGasPayerChipToggled(
    MarkDetailGasPayerChipToggled event,
    Emitter<MarkDetailState> emit,
  ) async {
    if (state is MarkDetailLoaded) {
      final current = state as MarkDetailLoaded;
      final isSameMember = current.draft.selectedGasPayer?.id == event.member.id;
      final newGasPayer = isSameMember ? null : event.member;
      emit(current.copyWith(
        draft: current.draft.copyWith(selectedGasPayer: newGasPayer),
      ));
    }
  }
}
