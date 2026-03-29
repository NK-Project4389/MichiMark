import 'package:equatable/equatable.dart';
import '../draft/member_setting_detail_draft.dart';

// ── Delegate ─────────────────────────────────────────────────────────────────

sealed class MemberSettingDetailDelegate extends Equatable {
  const MemberSettingDetailDelegate();
}

class MemberSettingDetailDidSaveDelegate extends MemberSettingDetailDelegate {
  const MemberSettingDetailDidSaveDelegate();

  @override
  List<Object?> get props => [];
}

class MemberSettingDetailDismissDelegate extends MemberSettingDetailDelegate {
  const MemberSettingDetailDismissDelegate();

  @override
  List<Object?> get props => [];
}

// ── State ─────────────────────────────────────────────────────────────────────

sealed class MemberSettingDetailState extends Equatable {
  const MemberSettingDetailState();
}

class MemberSettingDetailLoading extends MemberSettingDetailState {
  const MemberSettingDetailLoading();

  @override
  List<Object?> get props => [];
}

class MemberSettingDetailLoaded extends MemberSettingDetailState {
  final String memberId;
  final MemberSettingDetailDraft draft;
  final String? validationError;
  final String? saveErrorMessage;
  final bool isSaving;
  final MemberSettingDetailDelegate? delegate;

  const MemberSettingDetailLoaded({
    required this.memberId,
    required this.draft,
    this.validationError,
    this.saveErrorMessage,
    this.isSaving = false,
    this.delegate,
  });

  MemberSettingDetailLoaded copyWith({
    MemberSettingDetailDraft? draft,
    String? validationError,
    String? saveErrorMessage,
    bool? isSaving,
    MemberSettingDetailDelegate? delegate,
    bool clearValidationError = false,
    bool clearSaveError = false,
  }) {
    return MemberSettingDetailLoaded(
      memberId: memberId,
      draft: draft ?? this.draft,
      validationError: clearValidationError ? null : (validationError ?? this.validationError),
      saveErrorMessage: clearSaveError ? null : (saveErrorMessage ?? this.saveErrorMessage),
      isSaving: isSaving ?? this.isSaving,
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props => [
        memberId,
        draft,
        validationError,
        saveErrorMessage,
        isSaving,
        delegate,
      ];
}

class MemberSettingDetailError extends MemberSettingDetailState {
  final String message;
  const MemberSettingDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
