import 'package:equatable/equatable.dart';
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

class PaymentDetailOpenMemberSelectionDelegate extends PaymentDetailDelegate {
  const PaymentDetailOpenMemberSelectionDelegate();

  @override
  List<Object?> get props => [];
}

class PaymentDetailOpenSplitMembersSelectionDelegate
    extends PaymentDetailDelegate {
  const PaymentDetailOpenSplitMembersSelectionDelegate();

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
  final PaymentDetailDelegate? delegate;
  final bool isSaving;

  const PaymentDetailLoaded({
    required this.draft,
    this.delegate,
    this.isSaving = false,
  });

  PaymentDetailLoaded copyWith({
    PaymentDetailDraft? draft,
    PaymentDetailDelegate? delegate,
    bool? isSaving,
  }) {
    return PaymentDetailLoaded(
      draft: draft ?? this.draft,
      delegate: delegate,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [draft, delegate, isSaving];
}

class PaymentDetailError extends PaymentDetailState {
  final String message;
  const PaymentDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
