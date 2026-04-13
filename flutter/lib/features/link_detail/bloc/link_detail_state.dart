import 'package:equatable/equatable.dart';
import '../../../domain/master/member/member_domain.dart';
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

  /// 画面オープン時の初期状態スナップショット。差分比較に使用する
  final LinkDetailDraft initialDraft;

  final LinkDetailDelegate? delegate;
  final TopicConfig topicConfig;
  final bool isSaving;

  /// true のとき Page が CupertinoAlertDialog を表示する
  final bool showCancelConfirmDialog;

  /// メンバー選択 UI に表示する候補一覧（イベントメンバーに限定）
  final List<MemberDomain> availableMembers;

  const LinkDetailLoaded({
    required this.draft,
    required this.initialDraft,
    this.delegate,
    TopicConfig? topicConfig,
    this.isSaving = false,
    this.showCancelConfirmDialog = false,
    this.availableMembers = const [],
  }) : topicConfig = topicConfig ?? const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        );

  LinkDetailLoaded copyWith({
    LinkDetailDraft? draft,
    LinkDetailDraft? initialDraft,
    LinkDetailDelegate? delegate,
    TopicConfig? topicConfig,
    bool? isSaving,
    bool? showCancelConfirmDialog,
    List<MemberDomain>? availableMembers,
  }) {
    return LinkDetailLoaded(
      draft: draft ?? this.draft,
      initialDraft: initialDraft ?? this.initialDraft,
      delegate: delegate,
      topicConfig: topicConfig ?? this.topicConfig,
      isSaving: isSaving ?? this.isSaving,
      showCancelConfirmDialog: showCancelConfirmDialog ?? this.showCancelConfirmDialog,
      availableMembers: availableMembers ?? this.availableMembers,
    );
  }

  @override
  List<Object?> get props => [draft, initialDraft, delegate, topicConfig, isSaving, showCancelConfirmDialog, availableMembers];
}

class LinkDetailError extends LinkDetailState {
  final String message;
  const LinkDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
