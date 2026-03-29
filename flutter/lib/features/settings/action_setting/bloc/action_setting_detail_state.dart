import 'package:equatable/equatable.dart';
import '../draft/action_setting_detail_draft.dart';

// ── Delegate ─────────────────────────────────────────────────────────────────

sealed class ActionSettingDetailDelegate extends Equatable {
  const ActionSettingDetailDelegate();
}

class ActionSettingDetailDidSaveDelegate extends ActionSettingDetailDelegate {
  const ActionSettingDetailDidSaveDelegate();

  @override
  List<Object?> get props => [];
}

class ActionSettingDetailDismissDelegate extends ActionSettingDetailDelegate {
  const ActionSettingDetailDismissDelegate();

  @override
  List<Object?> get props => [];
}

// ── State ─────────────────────────────────────────────────────────────────────

sealed class ActionSettingDetailState extends Equatable {
  const ActionSettingDetailState();
}

class ActionSettingDetailLoading extends ActionSettingDetailState {
  const ActionSettingDetailLoading();

  @override
  List<Object?> get props => [];
}

class ActionSettingDetailLoaded extends ActionSettingDetailState {
  final String actionId;
  final ActionSettingDetailDraft draft;
  final String? validationError;
  final String? saveErrorMessage;
  final bool isSaving;
  final ActionSettingDetailDelegate? delegate;

  const ActionSettingDetailLoaded({
    required this.actionId,
    required this.draft,
    this.validationError,
    this.saveErrorMessage,
    this.isSaving = false,
    this.delegate,
  });

  ActionSettingDetailLoaded copyWith({
    ActionSettingDetailDraft? draft,
    String? validationError,
    String? saveErrorMessage,
    bool? isSaving,
    ActionSettingDetailDelegate? delegate,
    bool clearValidationError = false,
    bool clearSaveError = false,
  }) {
    return ActionSettingDetailLoaded(
      actionId: actionId,
      draft: draft ?? this.draft,
      validationError: clearValidationError ? null : (validationError ?? this.validationError),
      saveErrorMessage: clearSaveError ? null : (saveErrorMessage ?? this.saveErrorMessage),
      isSaving: isSaving ?? this.isSaving,
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props => [
        actionId,
        draft,
        validationError,
        saveErrorMessage,
        isSaving,
        delegate,
      ];
}

class ActionSettingDetailError extends ActionSettingDetailState {
  final String message;
  const ActionSettingDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
