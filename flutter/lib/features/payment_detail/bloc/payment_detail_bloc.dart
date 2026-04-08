import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
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
    on<PaymentDetailEditMemberPressed>(_onEditMemberPressed);
    on<PaymentDetailMemberSelected>(_onMemberSelected);
    on<PaymentDetailEditSplitMembersPressed>(_onEditSplitMembersPressed);
    on<PaymentDetailSplitMembersSelected>(_onSplitMembersSelected);
    on<PaymentDetailMemoChanged>(_onMemoChanged);
    on<PaymentDetailSaveTapped>(_onSaveTapped);
    on<PaymentDetailCancelTapped>(_onCancelTapped);
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
      if (event.paymentId == null) {
        // 新規作成: 初期Draftを生成
        final draft = PaymentDetailDraft(
          id: const Uuid().v4(),
          paymentSeq: 0,
        );
        emit(PaymentDetailLoaded(draft: draft));
        return;
      }
      // 既存編集: Repositoryからデータ取得
      final domain = await _eventRepository.fetch(event.eventId);
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
      emit(PaymentDetailLoaded(draft: draft));
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

  Future<void> _onEditMemberPressed(
    PaymentDetailEditMemberPressed event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      emit(current.copyWith(
        delegate: const PaymentDetailOpenMemberSelectionDelegate(),
      ));
    }
  }

  Future<void> _onMemberSelected(
    PaymentDetailMemberSelected event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(paymentMember: event.member),
      ));
    }
  }

  Future<void> _onEditSplitMembersPressed(
    PaymentDetailEditSplitMembersPressed event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      emit(current.copyWith(
        delegate: const PaymentDetailOpenSplitMembersSelectionDelegate(),
      ));
    }
  }

  Future<void> _onSplitMembersSelected(
    PaymentDetailSplitMembersSelected event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      emit(current.copyWith(
        draft: current.draft.copyWith(splitMembers: event.members),
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

      final amount = int.tryParse(draft.paymentAmount);
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
}
