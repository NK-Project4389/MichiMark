import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_config.dart';
import '../draft/link_detail_draft.dart';

/// LinkDetailのDelegate（画面遷移・操作意図の通知）
sealed class LinkDetailDelegate extends Equatable {
  const LinkDetailDelegate();
}

class LinkDetailDismissDelegate extends LinkDetailDelegate {
  const LinkDetailDismissDelegate();

  @override
  List<Object?> get props => [];
}

class LinkDetailOpenMembersSelectionDelegate extends LinkDetailDelegate {
  const LinkDetailOpenMembersSelectionDelegate();

  @override
  List<Object?> get props => [];
}

class LinkDetailOpenActionsSelectionDelegate extends LinkDetailDelegate {
  const LinkDetailOpenActionsSelectionDelegate();

  @override
  List<Object?> get props => [];
}

class LinkDetailSavedDelegate extends LinkDetailDelegate {
  final String markLinkId;
  final LinkDetailDraft draft;
  const LinkDetailSavedDelegate({required this.markLinkId, required this.draft});

  @override
  List<Object?> get props => [markLinkId, draft];
}

class LinkDetailSaveErrorDelegate extends LinkDetailDelegate {
  final String message;
  const LinkDetailSaveErrorDelegate(this.message);

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------

sealed class LinkDetailState extends Equatable {
  const LinkDetailState();
}

class LinkDetailLoading extends LinkDetailState {
  const LinkDetailLoading();

  @override
  List<Object?> get props => [];
}

class LinkDetailLoaded extends LinkDetailState {
  final LinkDetailDraft draft;
  final LinkDetailDelegate? delegate;
  final TopicConfig topicConfig;
  final bool isSaving;

  const LinkDetailLoaded({
    required this.draft,
    this.delegate,
    TopicConfig? topicConfig,
    this.isSaving = false,
  }) : topicConfig = topicConfig ?? const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          allowLinkAdd: true,
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        );

  LinkDetailLoaded copyWith({
    LinkDetailDraft? draft,
    LinkDetailDelegate? delegate,
    TopicConfig? topicConfig,
    bool? isSaving,
  }) {
    return LinkDetailLoaded(
      draft: draft ?? this.draft,
      delegate: delegate,
      topicConfig: topicConfig ?? this.topicConfig,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [draft, delegate, topicConfig, isSaving];
}

class LinkDetailError extends LinkDetailState {
  final String message;
  const LinkDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
