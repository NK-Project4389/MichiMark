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

class LinkDetailSaveDraftDelegate extends LinkDetailDelegate {
  final LinkDetailDraft draft;
  const LinkDetailSaveDraftDelegate(this.draft);

  @override
  List<Object?> get props => [draft];
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

  const LinkDetailLoaded({
    required this.draft,
    this.delegate,
    TopicConfig? topicConfig,
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
  }) {
    return LinkDetailLoaded(
      draft: draft ?? this.draft,
      delegate: delegate,
      topicConfig: topicConfig ?? this.topicConfig,
    );
  }

  @override
  List<Object?> get props => [draft, delegate, topicConfig];
}

class LinkDetailError extends LinkDetailState {
  final String message;
  const LinkDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
