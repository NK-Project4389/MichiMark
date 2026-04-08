import 'package:equatable/equatable.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../features/event_detail/projection/michi_info_list_projection.dart';
import '../../../features/shared/projection/action_item_projection.dart';
import '../draft/michi_info_draft.dart';

/// MichiInfoのDelegate（画面遷移・操作意図の通知）
sealed class MichiInfoDelegate extends Equatable {
  const MichiInfoDelegate();
}

/// マーク詳細へ遷移
class MichiInfoOpenMarkDelegate extends MichiInfoDelegate {
  final String eventId;
  final String markLinkId;
  final TopicConfig topicConfig;
  final List<MemberDomain> eventMembers;
  const MichiInfoOpenMarkDelegate({
    required this.eventId,
    required this.markLinkId,
    required this.topicConfig,
    this.eventMembers = const [],
  });

  @override
  List<Object?> get props => [eventId, markLinkId, topicConfig, eventMembers];
}

/// リンク詳細へ遷移
class MichiInfoOpenLinkDelegate extends MichiInfoDelegate {
  final String eventId;
  final String markLinkId;
  final TopicConfig topicConfig;
  final List<MemberDomain> eventMembers;
  const MichiInfoOpenLinkDelegate({
    required this.eventId,
    required this.markLinkId,
    required this.topicConfig,
    this.eventMembers = const [],
  });

  @override
  List<Object?> get props => [eventId, markLinkId, topicConfig, eventMembers];
}

/// 新規マーク追加画面へ遷移
class MichiInfoAddMarkDelegate extends MichiInfoDelegate {
  final String eventId;
  final TopicConfig topicConfig;

  /// REQ-MAD-001: メーター初期値
  final String initialMeterValueInput;

  /// REQ-MAD-002: メンバー初期値
  final List<MemberDomain> initialSelectedMembers;

  /// REQ-MAD-003: 日付初期値（null の場合は MarkDetailBloc で DateTime.now() を使用）
  final DateTime? initialMarkLinkDate;

  /// REQ-MAD-004: メンバー選択候補（イベントメンバー一覧）
  final List<MemberDomain> eventMembers;

  const MichiInfoAddMarkDelegate(
    this.eventId,
    this.topicConfig, {
    this.initialMeterValueInput = '',
    this.initialSelectedMembers = const [],
    this.initialMarkLinkDate,
    this.eventMembers = const [],
  });

  @override
  List<Object?> get props => [
        eventId,
        topicConfig,
        initialMeterValueInput,
        initialSelectedMembers,
        initialMarkLinkDate,
        eventMembers,
      ];
}

/// Mark/Link 保存後の再読込完了を EventDetail に通知するデリゲート
class MichiInfoReloadedDelegate extends MichiInfoDelegate {
  const MichiInfoReloadedDelegate();

  @override
  List<Object?> get props => [];
}

/// 新規リンク追加画面へ遷移
class MichiInfoAddLinkDelegate extends MichiInfoDelegate {
  final String eventId;
  final TopicConfig topicConfig;
  final List<MemberDomain> eventMembers;
  const MichiInfoAddLinkDelegate(this.eventId, this.topicConfig, {
    this.eventMembers = const [],
  });

  @override
  List<Object?> get props => [eventId, topicConfig, eventMembers];
}

// ---------------------------------------------------------------------------

sealed class MichiInfoState extends Equatable {
  const MichiInfoState();
}

class MichiInfoLoading extends MichiInfoState {
  const MichiInfoLoading();

  @override
  List<Object?> get props => [];
}

class MichiInfoLoaded extends MichiInfoState {
  final MichiInfoListProjection projection;
  final MichiInfoDraft draft;
  final MichiInfoDelegate? delegate;
  final TopicConfig topicConfig;

  /// 地点（マーク）に表示するアクションボタン一覧（TopicConfig.markActions から生成）
  final List<ActionItemProjection> markActionItems;

  /// イベントのメンバー一覧（Mark/Link のメンバー選択候補として使用）
  final List<MemberDomain> eventMembers;

  const MichiInfoLoaded({
    required this.projection,
    required this.draft,
    this.delegate,
    TopicConfig? topicConfig,
    this.markActionItems = const [],
    this.eventMembers = const [],
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

  MichiInfoLoaded copyWith({
    MichiInfoListProjection? projection,
    MichiInfoDraft? draft,
    MichiInfoDelegate? delegate,
    TopicConfig? topicConfig,
    List<ActionItemProjection>? markActionItems,
    List<MemberDomain>? eventMembers,
  }) {
    return MichiInfoLoaded(
      projection: projection ?? this.projection,
      draft: draft ?? this.draft,
      delegate: delegate,
      topicConfig: topicConfig ?? this.topicConfig,
      markActionItems: markActionItems ?? this.markActionItems,
      eventMembers: eventMembers ?? this.eventMembers,
    );
  }

  @override
  List<Object?> get props => [projection, draft, delegate, topicConfig, markActionItems, eventMembers];
}

class MichiInfoError extends MichiInfoState {
  final String message;
  const MichiInfoError({required this.message});

  @override
  List<Object?> get props => [message];
}
