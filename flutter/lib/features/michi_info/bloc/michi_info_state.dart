import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../features/event_detail/projection/michi_info_list_projection.dart';
import '../draft/michi_info_draft.dart';

/// MichiInfoのDelegate（画面遷移・操作意図の通知）
sealed class MichiInfoDelegate extends Equatable {
  const MichiInfoDelegate();
}

/// マーク詳細へ遷移
class MichiInfoOpenMarkDelegate extends MichiInfoDelegate {
  final String eventId;
  final String markLinkId;
  const MichiInfoOpenMarkDelegate({required this.eventId, required this.markLinkId});

  @override
  List<Object?> get props => [eventId, markLinkId];
}

/// リンク詳細へ遷移
class MichiInfoOpenLinkDelegate extends MichiInfoDelegate {
  final String eventId;
  final String markLinkId;
  const MichiInfoOpenLinkDelegate({required this.eventId, required this.markLinkId});

  @override
  List<Object?> get props => [eventId, markLinkId];
}

/// 新規マーク追加画面へ遷移
class MichiInfoAddMarkDelegate extends MichiInfoDelegate {
  final String eventId;
  const MichiInfoAddMarkDelegate(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// 新規リンク追加画面へ遷移
class MichiInfoAddLinkDelegate extends MichiInfoDelegate {
  final String eventId;
  const MichiInfoAddLinkDelegate(this.eventId);

  @override
  List<Object?> get props => [eventId];
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

  const MichiInfoLoaded({
    required this.projection,
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

  MichiInfoLoaded copyWith({
    MichiInfoListProjection? projection,
    MichiInfoDraft? draft,
    MichiInfoDelegate? delegate,
    TopicConfig? topicConfig,
  }) {
    return MichiInfoLoaded(
      projection: projection ?? this.projection,
      draft: draft ?? this.draft,
      delegate: delegate,
      topicConfig: topicConfig ?? this.topicConfig,
    );
  }

  @override
  List<Object?> get props => [projection, draft, delegate, topicConfig];
}

class MichiInfoError extends MichiInfoState {
  final String message;
  const MichiInfoError({required this.message});

  @override
  List<Object?> get props => [message];
}
