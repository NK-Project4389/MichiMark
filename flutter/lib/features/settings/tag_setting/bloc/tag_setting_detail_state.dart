import 'package:equatable/equatable.dart';
import '../draft/tag_setting_detail_draft.dart';

// ── Delegate ─────────────────────────────────────────────────────────────────

sealed class TagSettingDetailDelegate extends Equatable {
  const TagSettingDetailDelegate();
}

class TagSettingDetailDidSaveDelegate extends TagSettingDetailDelegate {
  const TagSettingDetailDidSaveDelegate();

  @override
  List<Object?> get props => [];
}

class TagSettingDetailDismissDelegate extends TagSettingDetailDelegate {
  const TagSettingDetailDismissDelegate();

  @override
  List<Object?> get props => [];
}

// ── State ─────────────────────────────────────────────────────────────────────

sealed class TagSettingDetailState extends Equatable {
  const TagSettingDetailState();
}

class TagSettingDetailLoading extends TagSettingDetailState {
  const TagSettingDetailLoading();

  @override
  List<Object?> get props => [];
}

class TagSettingDetailLoaded extends TagSettingDetailState {
  final String tagId;
  final TagSettingDetailDraft draft;
  final String? validationError;
  final String? saveErrorMessage;
  final bool isSaving;
  final TagSettingDetailDelegate? delegate;

  const TagSettingDetailLoaded({
    required this.tagId,
    required this.draft,
    this.validationError,
    this.saveErrorMessage,
    this.isSaving = false,
    this.delegate,
  });

  TagSettingDetailLoaded copyWith({
    TagSettingDetailDraft? draft,
    String? validationError,
    String? saveErrorMessage,
    bool? isSaving,
    TagSettingDetailDelegate? delegate,
    bool clearValidationError = false,
    bool clearSaveError = false,
  }) {
    return TagSettingDetailLoaded(
      tagId: tagId,
      draft: draft ?? this.draft,
      validationError: clearValidationError ? null : (validationError ?? this.validationError),
      saveErrorMessage: clearSaveError ? null : (saveErrorMessage ?? this.saveErrorMessage),
      isSaving: isSaving ?? this.isSaving,
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props => [
        tagId,
        draft,
        validationError,
        saveErrorMessage,
        isSaving,
        delegate,
      ];
}

class TagSettingDetailError extends TagSettingDetailState {
  final String message;
  const TagSettingDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
