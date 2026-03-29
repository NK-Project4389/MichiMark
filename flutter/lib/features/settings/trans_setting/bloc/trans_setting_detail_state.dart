import 'package:equatable/equatable.dart';
import '../draft/trans_setting_detail_draft.dart';

// ── Delegate ─────────────────────────────────────────────────────────────────

sealed class TransSettingDetailDelegate extends Equatable {
  const TransSettingDetailDelegate();
}

class TransSettingDetailDidSaveDelegate extends TransSettingDetailDelegate {
  const TransSettingDetailDidSaveDelegate();

  @override
  List<Object?> get props => [];
}

class TransSettingDetailDismissDelegate extends TransSettingDetailDelegate {
  const TransSettingDetailDismissDelegate();

  @override
  List<Object?> get props => [];
}

// ── State ─────────────────────────────────────────────────────────────────────

sealed class TransSettingDetailState extends Equatable {
  const TransSettingDetailState();
}

class TransSettingDetailLoading extends TransSettingDetailState {
  const TransSettingDetailLoading();

  @override
  List<Object?> get props => [];
}

class TransSettingDetailLoaded extends TransSettingDetailState {
  final String transId;
  final TransSettingDetailDraft draft;

  /// バリデーションエラー（フィールド別）
  final String? nameError;
  final String? kmPerGasError;
  final String? meterValueError;

  final String? saveErrorMessage;
  final bool isSaving;
  final TransSettingDetailDelegate? delegate;

  const TransSettingDetailLoaded({
    required this.transId,
    required this.draft,
    this.nameError,
    this.kmPerGasError,
    this.meterValueError,
    this.saveErrorMessage,
    this.isSaving = false,
    this.delegate,
  });

  TransSettingDetailLoaded copyWith({
    TransSettingDetailDraft? draft,
    String? nameError,
    String? kmPerGasError,
    String? meterValueError,
    String? saveErrorMessage,
    bool? isSaving,
    TransSettingDetailDelegate? delegate,
    bool clearNameError = false,
    bool clearKmPerGasError = false,
    bool clearMeterValueError = false,
    bool clearSaveError = false,
  }) {
    return TransSettingDetailLoaded(
      transId: transId,
      draft: draft ?? this.draft,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      kmPerGasError: clearKmPerGasError ? null : (kmPerGasError ?? this.kmPerGasError),
      meterValueError: clearMeterValueError ? null : (meterValueError ?? this.meterValueError),
      saveErrorMessage: clearSaveError ? null : (saveErrorMessage ?? this.saveErrorMessage),
      isSaving: isSaving ?? this.isSaving,
      delegate: delegate,
    );
  }

  bool get hasValidationError =>
      nameError != null || kmPerGasError != null || meterValueError != null;

  @override
  List<Object?> get props => [
        transId,
        draft,
        nameError,
        kmPerGasError,
        meterValueError,
        saveErrorMessage,
        isSaving,
        delegate,
      ];
}

class TransSettingDetailError extends TransSettingDetailState {
  final String message;
  const TransSettingDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
