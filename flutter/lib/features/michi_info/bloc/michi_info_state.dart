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
  const MichiInfoOpenMarkDelegate({
    required this.eventId,
    required this.markLinkId,
    required this.topicConfig,
  });

  @override
  List<Object?> get props => [eventId, markLinkId, topicConfig];
}

/// リンク詳細へ遷移
class MichiInfoOpenLinkDelegate extends MichiInfoDelegate {
  final String eventId;
  final String markLinkId;
  final TopicConfig topicConfig;
  const MichiInfoOpenLinkDelegate({
    required this.eventId,
    required this.markLinkId,
    required this.topicConfig,
  });

  @override
  List<Object?> get props => [eventId, markLinkId, topicConfig];
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

/// 新規リンク追加画面へ遷移
class MichiInfoAddLinkDelegate extends MichiInfoDelegate {
  final String eventId;
  final TopicConfig topicConfig;
  const MichiInfoAddLinkDelegate(this.eventId, this.topicConfig);

  @override
  List<Object?> get props => [eventId, topicConfig];
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

  const MichiInfoLoaded({
    required this.projection,
    required this.draft,
    this.delegate,
    TopicConfig? topicConfig,
    this.markActionItems = const [],
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
  }) {
    return MichiInfoLoaded(
      projection: projection ?? this.projection,
      draft: draft ?? this.draft,
      delegate: delegate,
      topicConfig: topicConfig ?? this.topicConfig,
      markActionItems: markActionItems ?? this.markActionItems,
    );
  }

  @override
  List<Object?> get props => [projection, draft, delegate, topicConfig, markActionItems];
}

class MichiInfoError extends MichiInfoState {
  final String message;
  const MichiInfoError({required this.message});

  @override
  List<Object?> get props => [message];
}
