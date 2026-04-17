import 'package:equatable/equatable.dart';
import '../../../domain/master/member/member_domain.dart';
import '../draft/payment_detail_draft.dart';

/// PaymentDetailの遷移意図（BlocListenerがNavigation処理）
sealed class PaymentDetailDelegate extends Equatable {
  const PaymentDetailDelegate();
}

class PaymentDetailSavedDelegate extends PaymentDetailDelegate {
  final PaymentDetailDraft draft;
  const PaymentDetailSavedDelegate(this.draft);

  @override
  List<Object?> get props => [draft];
}

class PaymentDetailSaveErrorDelegate extends PaymentDetailDelegate {
  final String message;
  const PaymentDetailSaveErrorDelegate(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentDetailDismissDelegate extends PaymentDetailDelegate {
  const PaymentDetailDismissDelegate();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------

sealed class PaymentDetailState extends Equatable {
  const PaymentDetailState();
}

class PaymentDetailLoading extends PaymentDetailState {
  const PaymentDetailLoading();

  @override
  List<Object?> get props => [];
}

class PaymentDetailLoaded extends PaymentDetailState {
  final PaymentDetailDraft draft;

  /// 画面オープン時の初期状態スナップショット。差分比較に使用する
  final PaymentDetailDraft initialDraft;

  final PaymentDetailDelegate? delegate;
  final bool isSaving;

  /// true のとき Page が CupertinoAlertDialog を表示する
  final bool showCancelConfirmDialog;

  /// 概要（BasicInfo）の参加メンバー。支払者・割り勘の選択肢を絞り込むために使用する。
  final List<MemberDomain> availableMembers;

  /// メンバーセクション（支払者・割り勘）を表示するか（F-6: visitWork以外はtrue）
  final bool showMemberSection;

  const PaymentDetailLoaded({
    required this.draft,
    required this.initialDraft,
    this.delegate,
    this.isSaving = false,
    this.showCancelConfirmDialog = false,
    this.availableMembers = const [],
    this.showMemberSection = true,
  });

  PaymentDetailLoaded copyWith({
    PaymentDetailDraft? draft,
    PaymentDetailDraft? initialDraft,
    PaymentDetailDelegate? delegate,
    bool? isSaving,
    bool? showCancelConfirmDialog,
    List<MemberDomain>? availableMembers,
    bool? showMemberSection,
  }) {
    return PaymentDetailLoaded(
      draft: draft ?? this.draft,
      initialDraft: initialDraft ?? this.initialDraft,
      delegate: delegate,
      isSaving: isSaving ?? this.isSaving,
      showCancelConfirmDialog: showCancelConfirmDialog ?? this.showCancelConfirmDialog,
      availableMembers: availableMembers ?? this.availableMembers,
      showMemberSection: showMemberSection ?? this.showMemberSection,
    );
  }

  @override
  List<Object?> get props => [draft, initialDraft, delegate, isSaving, showCancelConfirmDialog, availableMembers, showMemberSection];
}

class PaymentDetailError extends PaymentDetailState {
  final String message;
  const PaymentDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
