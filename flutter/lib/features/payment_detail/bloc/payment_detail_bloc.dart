import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/transaction/payment/payment_domain.dart';
import '../../../repository/event_repository.dart';
import '../../../repository/member_repository.dart';
import '../draft/payment_detail_draft.dart';
import 'payment_detail_event.dart';
import 'payment_detail_state.dart';

class PaymentDetailBloc
    extends Bloc<PaymentDetailEvent, PaymentDetailState> {
  PaymentDetailBloc({
    required EventRepository eventRepository,
    required MemberRepository memberRepository,
  })  : _eventRepository = eventRepository,
        _memberRepository = memberRepository,
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
    on<PaymentDetailCancelDiscardConfirmed>(_onCancelDiscardConfirmed);
    on<PaymentDetailCancelDialogDismissed>(_onCancelDialogDismissed);
  }

  final EventRepository _eventRepository;
  final MemberRepository _memberRepository;
  String _eventId = '';
  bool _showMemberSection = true;

  Future<void> _onStarted(
    PaymentDetailStarted event,
    Emitter<PaymentDetailState> emit,
  ) async {
    _eventId = event.eventId;
    emit(const PaymentDetailLoading());
    try {
      final domain = await _eventRepository.fetch(event.eventId);
      // F-6: visitWork以外はメンバーセクション表示
      _showMemberSection = domain.topic?.topicType != TopicType.visitWork;
      // マスタMemberRepositoryから最新のisVisible状態を取得してフィルタ（B-10修正）
      final masterMembers = await _memberRepository.fetchAll();
      final visibleMasterIds = masterMembers.where((m) => m.isVisible).map((m) => m.id).toSet();
      final availableMembers = domain.members
          .where((m) => visibleMasterIds.contains(m.id))
          .toList();

      if (event.paymentId == null) {
        // 新規作成: 初期Draftを生成
        final draft = PaymentDetailDraft(
          id: const Uuid().v4(),
          paymentSeq: 0,
          markLinkID: event.markLinkID,
        );
        emit(PaymentDetailLoaded(draft: draft, initialDraft: draft, availableMembers: availableMembers, showMemberSection: _showMemberSection));
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
      // 後から非表示になったメンバーを除外する（B-10修正）
      final visibleMemberIds = availableMembers.map((m) => m.id).toSet();
      final filteredPayMember =
          visibleMemberIds.contains(payment.paymentMember.id)
              ? payment.paymentMember
              : null;
      final filteredSplitMembers = payment.splitMembers
          .where((m) => visibleMemberIds.contains(m.id))
          .toList();
      final draft = PaymentDetailDraft(
        id: payment.id,
        paymentSeq: payment.paymentSeq,
        paymentAmount: payment.paymentAmount.toString(),
        paymentMember: filteredPayMember,
        splitMembers: filteredSplitMembers,
        paymentMemo: payment.paymentMemo ?? '',
        markLinkID: payment.markLinkID,
      );
      emit(PaymentDetailLoaded(draft: draft, initialDraft: draft, availableMembers: availableMembers, showMemberSection: _showMemberSection));
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
        markLinkID: draft.markLinkID,
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
          markLinkID: draft.markLinkID,
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
      if (current.draft == current.initialDraft) {
        // 差分なし: そのまま Dismiss
        emit(current.copyWith(delegate: const PaymentDetailDismissDelegate()));
      } else {
        // 差分あり: 確認ダイアログを表示
        emit(current.copyWith(showCancelConfirmDialog: true));
      }
    }
  }

  Future<void> _onCancelDiscardConfirmed(
    PaymentDetailCancelDiscardConfirmed event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      emit(current.copyWith(
        draft: current.initialDraft,
        showCancelConfirmDialog: false,
        delegate: const PaymentDetailDismissDelegate(),
      ));
    }
  }

  Future<void> _onCancelDialogDismissed(
    PaymentDetailCancelDialogDismissed event,
    Emitter<PaymentDetailState> emit,
  ) async {
    if (state is PaymentDetailLoaded) {
      final current = state as PaymentDetailLoaded;
      emit(current.copyWith(showCancelConfirmDialog: false));
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
