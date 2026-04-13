import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/transaction/payment/payment_domain.dart';
import '../../../repository/event_repository.dart';
import '../draft/payment_detail_draft.dart';
import 'payment_detail_event.dart';
import 'payment_detail_state.dart';

class PaymentDetailBloc
    extends Bloc<PaymentDetailEvent, PaymentDetailState> {
  PaymentDetailBloc({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const PaymentDetailLoading()) {
    on<PaymentDetailStarted>(_onStarted);
    on<PaymentDetailAmountChanged>(_onAmountChanged);
    on<PaymentDetailPayMemberChipToggled>(_onPayMemberChipToggled);
    on<PaymentDetailSplitMemberChipToggled>(_onSplitMemberChipToggled);
    on<PaymentDetailMemoChanged>(_onMemoChanged);
    on<PaymentDetailSaveTapped>(_onSaveTapped);
    on<PaymentDetailCancelTapped>(_onCancelTapped);
    on<PaymentDetailSplitMembersAllSelected>(_onSplitMembersAllSelected);
    on<PaymentDetailSplitMembersAllCleared>(_onSplitMembersAllCleared);
  }

  final EventRepository _eventRepository;
  String _eventId = '';

  Future<void> _onStarted(
    PaymentDetailStarted event,
    Emitter<PaymentDetailState> emit,
  ) async {
    _eventId = event.eventId;
    emit(const PaymentDetailLoading());
    try {
      final domain = await _eventRepository.fetch(event.eventId);
      final availableMembers = domain.members;

      if (event.paymentId == null) {
        // 新規作成: 初期Draftを生成
        final draft = PaymentDetailDraft(
          id: const Uuid().v4(),
          paymentSeq: 0,
        );
        emit(PaymentDetailLoaded(draft: draft, availableMembers: availableMembers));
        return;
      }
      // 既存編集: Repositoryからデータ取得
      final payment = domain.payments
          .where((p) => p.id == event.paymentId && !p.isDeleted)
          .firstOrNull;
      if (payment == null) {
        emit(const PaymentDetailError(message: '支払情報が見つかりません'));
        return;
      }
      final draft = PaymentDetailDraft(
        id: payment.id,
        paymentSeq: payment.paymentSeq,
        paymentAmount: payment.paymentAmount.toString(),
        paymentMember: payment.paymentMember,
        splitMembers: payment.splitMembers,
        paymentMemo: payment.paymentMemo ?? '',
      );
      emit(PaymentDetailLoaded(draft: draft, availableMembers: availableMembers));
    } on Exception catch (e) {
      emit(PaymentDetailError(message: e.toString()));
    }
  }

  Future<void> _onAmountChanged(
    PaymentDetailAmountChanged event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(paymentAmount: event.value),
      ));
    }
  }

  Future<void> _onPayMemberChipToggled(
    PaymentDetailPayMemberChipToggled event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      final draft = current.draft;
      final MemberDomain? newPayMember;
      if (draft.paymentMember?.id == event.member.id) {
        // 同一メンバーをタップ → 選択解除
        newPayMember = null;
      } else {
        // 別メンバーをタップ → 選択切り替え
        newPayMember = event.member;
      }
      // 新支払者がsplitMembersに含まれていない場合は追加
      List<MemberDomain> splitMembers = List.from(draft.splitMembers);
      final payMember = newPayMember;
      if (payMember != null && !splitMembers.any((m) => m.id == payMember.id)) {
        splitMembers.add(payMember);
      }
      // paymentMemberをnullにできるよう直接コンストラクタで新しいDraftを生成
      final newDraft = PaymentDetailDraft(
        id: draft.id,
        paymentSeq: draft.paymentSeq,
        paymentAmount: draft.paymentAmount,
        paymentMember: newPayMember,
        splitMembers: splitMembers,
        paymentMemo: draft.paymentMemo,
      );
      emit(current.copyWith(draft: newDraft));
    }
  }

  Future<void> _onSplitMemberChipToggled(
    PaymentDetailSplitMemberChipToggled event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      final draft = current.draft;
      // 支払者は常にON固定（無視）
      if (draft.paymentMember?.id == event.member.id) return;
      final splitMembers = List<MemberDomain>.from(draft.splitMembers);
      final alreadySelected = splitMembers.any((m) => m.id == event.member.id);
      if (alreadySelected) {
        splitMembers.removeWhere((m) => m.id == event.member.id);
      } else {
        splitMembers.add(event.member);
      }
      emit(current.copyWith(
        draft: draft.copyWith(splitMembers: splitMembers),
      ));
    }
  }

  Future<void> _onMemoChanged(
    PaymentDetailMemoChanged event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(paymentMemo: event.value),
      ));
    }
  }

  Future<void> _onSaveTapped(
    PaymentDetailSaveTapped event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      final draft = current.draft;

      // paymentMember が未選択の場合は保存不可
      final paymentMember = draft.paymentMember;
      if (paymentMember == null) return;

      final amount = int.tryParse(draft.paymentAmount.replaceAll(',', ''));
      if (amount == null) return;

      emit(current.copyWith(isSaving: true));
      try {
        final existing = await _eventRepository.fetch(_eventId);
        final existingPayment = existing.payments
            .where((p) => p.id == draft.id && !p.isDeleted)
            .firstOrNull;

        final now = DateTime.now();
        final newPayment = PaymentDomain(
          id: draft.id,
          paymentSeq: existingPayment?.paymentSeq ?? draft.paymentSeq,
          paymentAmount: amount,
          paymentMember: paymentMember,
          splitMembers: draft.splitMembers,
          paymentMemo: draft.paymentMemo.isEmpty ? null : draft.paymentMemo,
          createdAt: existingPayment?.createdAt ?? now,
          updatedAt: now,
        );

        final updatedPayments = List<PaymentDomain>.from(
          existing.payments.where((p) => p.id != draft.id),
        )..add(newPayment);

        final updated = existing.copyWith(
          payments: updatedPayments,
          updatedAt: now,
        );
        await _eventRepository.save(updated);

        emit(current.copyWith(
          isSaving: false,
          delegate: PaymentDetailSavedDelegate(draft),
        ));
      } on Exception catch (e) {
        if (state case PaymentDetailLoaded loaded) {
          emit(loaded.copyWith(
            isSaving: false,
            delegate: PaymentDetailSaveErrorDelegate(e.toString()),
          ));
        }
      }
    }
  }

  Future<void> _onCancelTapped(
    PaymentDetailCancelTapped event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      emit(current.copyWith(
        delegate: const PaymentDetailDismissDelegate(),
      ));
    }
  }

  Future<void> _onSplitMembersAllSelected(
    PaymentDetailSplitMembersAllSelected event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(splitMembers: current.availableMembers),
      ));
    }
  }

  Future<void> _onSplitMembersAllCleared(
    PaymentDetailSplitMembersAllCleared event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      final payerId = current.draft.paymentMember?.id;
      final remainingMembers = payerId == null
          ? <MemberDomain>[]
          : current.availableMembers
              .where((m) => m.id == payerId)
              .toList();
      emit(current.copyWith(
        draft: current.draft.copyWith(splitMembers: remainingMembers),
      ));
    }
  }
}
