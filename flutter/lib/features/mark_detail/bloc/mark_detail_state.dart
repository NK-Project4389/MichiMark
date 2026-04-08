import 'package:equatable/equatable.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../draft/mark_detail_draft.dart';

/// MarkDetailのDelegate（画面遷移・操作意図の通知）
sealed class MarkDetailDelegate extends Equatable {
  const MarkDetailDelegate();
}

class MarkDetailDismissDelegate extends MarkDetailDelegate {
  const MarkDetailDismissDelegate();

  @override
  List<Object?> get props => [];
}

class MarkDetailOpenMembersSelectionDelegate extends MarkDetailDelegate {
  const MarkDetailOpenMembersSelectionDelegate();

  @override
  List<Object?> get props => [];
}

class MarkDetailOpenActionsSelectionDelegate extends MarkDetailDelegate {
  const MarkDetailOpenActionsSelectionDelegate();

  @override
  List<Object?> get props => [];
}

class MarkDetailSaveDraftDelegate extends MarkDetailDelegate {
  final MarkDetailDraft draft;
  const MarkDetailSaveDraftDelegate(this.draft);

  @override
  List<Object?> get props => [draft];
}

// ---------------------------------------------------------------------------

sealed class MarkDetailState extends Equatable {
  const MarkDetailState();
}

class MarkDetailLoading extends MarkDetailState {
  const MarkDetailLoading();

  @override
  List<Object?> get props => [];
}

class MarkDetailLoaded extends MarkDetailState {
  final MarkDetailDraft draft;
  final MarkDetailDelegate? delegate;
  final TopicConfig topicConfig;

  /// メンバー選択 UI に表示する候補一覧（イベントメンバーに限定）
  final List<MemberDomain> availableMembers;

  const MarkDetailLoaded({
    required this.draft,
    this.delegate,
    TopicConfig? topicConfig,
    this.availableMembers = const [],
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

  MarkDetailLoaded copyWith({
    MarkDetailDraft? draft,
    MarkDetailDelegate? delegate,
    TopicConfig? topicConfig,
    List<MemberDomain>? availableMembers,
  }) {
    return MarkDetailLoaded(
      draft: draft ?? this.draft,
      delegate: delegate,
      topicConfig: topicConfig ?? this.topicConfig,
      availableMembers: availableMembers ?? this.availableMembers,
    );
  }

  @override
  List<Object?> get props => [draft, delegate, topicConfig, availableMembers];
}

class MarkDetailError extends MarkDetailState {
  final String message;
  const MarkDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
