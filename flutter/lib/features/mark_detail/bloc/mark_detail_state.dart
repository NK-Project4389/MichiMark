import 'package:equatable/equatable.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../features/shared/projection/payment_section_projection.dart';
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

class MarkDetailOpenActionsSelectionDelegate extends MarkDetailDelegate {
  const MarkDetailOpenActionsSelectionDelegate();

  @override
  List<Object?> get props => [];
}

class MarkDetailSavedDelegate extends MarkDetailDelegate {
  final String markLinkId;
  final MarkDetailDraft draft;
  const MarkDetailSavedDelegate({required this.markLinkId, required this.draft});

  @override
  List<Object?> get props => [markLinkId, draft];
}

class MarkDetailSaveErrorDelegate extends MarkDetailDelegate {
  final String message;
  const MarkDetailSaveErrorDelegate(this.message);

  @override
  List<Object?> get props => [message];
}

/// 支払セクション「＋」ボタン → 新規PaymentDetail遷移要求
class MarkDetailOpenPaymentNewDelegate extends MarkDetailDelegate {
  final String markLinkId;
  const MarkDetailOpenPaymentNewDelegate(this.markLinkId);

  @override
  List<Object?> get props => [markLinkId];
}

/// 支払セクション既存カードタップ → PaymentDetail編集遷移要求
class MarkDetailOpenPaymentByIdDelegate extends MarkDetailDelegate {
  final String paymentId;
  const MarkDetailOpenPaymentByIdDelegate(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
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

  /// 画面オープン時の初期状態スナップショット。差分比較に使用する
  final MarkDetailDraft initialDraft;

  final MarkDetailDelegate? delegate;
  final TopicConfig topicConfig;
  final bool isSaving;

  /// true のとき Page が CupertinoAlertDialog を表示する
  final bool showCancelConfirmDialog;

  /// メンバー選択 UI に表示する候補一覧（イベントメンバーに限定）
  final List<MemberDomain> availableMembers;

  /// このMarkに紐づく支払い一覧
  final PaymentSectionProjection paymentSection;

  /// 親イベントID（PaymentDetail遷移時に使用）
  final String eventId;

  const MarkDetailLoaded({
    required this.draft,
    required this.initialDraft,
    this.delegate,
    TopicConfig? topicConfig,
    this.isSaving = false,
    this.showCancelConfirmDialog = false,
    this.availableMembers = const [],
    this.paymentSection = PaymentSectionProjection.empty,
    this.eventId = '',
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

  MarkDetailLoaded copyWith({
    MarkDetailDraft? draft,
    MarkDetailDraft? initialDraft,
    MarkDetailDelegate? delegate,
    TopicConfig? topicConfig,
    bool? isSaving,
    bool? showCancelConfirmDialog,
    List<MemberDomain>? availableMembers,
    PaymentSectionProjection? paymentSection,
    String? eventId,
  }) {
    return MarkDetailLoaded(
      draft: draft ?? this.draft,
      initialDraft: initialDraft ?? this.initialDraft,
      delegate: delegate,
      topicConfig: topicConfig ?? this.topicConfig,
      isSaving: isSaving ?? this.isSaving,
      showCancelConfirmDialog: showCancelConfirmDialog ?? this.showCancelConfirmDialog,
      availableMembers: availableMembers ?? this.availableMembers,
      paymentSection: paymentSection ?? this.paymentSection,
      eventId: eventId ?? this.eventId,
    );
  }

  @override
  List<Object?> get props => [draft, initialDraft, delegate, topicConfig, isSaving, showCancelConfirmDialog, availableMembers, paymentSection, eventId];
}

class MarkDetailError extends MarkDetailState {
  final String message;
  const MarkDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
