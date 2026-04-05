import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/transaction/event/event_domain.dart';
import '../draft/event_detail_draft.dart';
import '../projection/event_detail_projection.dart';

/// EventDetailのDelegate（画面遷移・操作意図の通知）
sealed class EventDetailDelegate extends Equatable {
  const EventDetailDelegate();
}

class EventDetailDismissDelegate extends EventDetailDelegate {
  const EventDetailDismissDelegate();

  @override
  List<Object?> get props => [];
}

class EventDetailOpenMarkDelegate extends EventDetailDelegate {
  final String markLinkId;
  const EventDetailOpenMarkDelegate(this.markLinkId);

  @override
  List<Object?> get props => [markLinkId];
}

class EventDetailOpenLinkDelegate extends EventDetailDelegate {
  final String markLinkId;
  const EventDetailOpenLinkDelegate(this.markLinkId);

  @override
  List<Object?> get props => [markLinkId];
}

class EventDetailOpenPaymentDelegate extends EventDetailDelegate {
  final String paymentId;
  const EventDetailOpenPaymentDelegate(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class EventDetailAddMarkLinkDelegate extends EventDetailDelegate {
  const EventDetailAddMarkLinkDelegate();

  @override
  List<Object?> get props => [];
}

class EventDetailSavedDelegate extends EventDetailDelegate {
  const EventDetailSavedDelegate();

  @override
  List<Object?> get props => [];
}

/// TopicConfig変更を子Blocへ伝播するようPageに通知する（起動時の一方向初期化用）
class EventDetailTopicConfigPropagateDelegate extends EventDetailDelegate {
  final TopicConfig topicConfig;
  const EventDetailTopicConfigPropagateDelegate(this.topicConfig);

  @override
  List<Object?> get props => [topicConfig];
}

// ---------------------------------------------------------------------------

sealed class EventDetailState extends Equatable {
  const EventDetailState();
}

class EventDetailLoading extends EventDetailState {
  const EventDetailLoading();

  @override
  List<Object?> get props => [];
}

class EventDetailLoaded extends EventDetailState {
  final EventDetailProjection projection;
  final EventDetailDraft draft;
  final EventDetailDelegate? delegate;
  final bool isSaving;
  final String? saveErrorMessage;
  final TopicConfig topicConfig;
  /// OverviewBlocにEventDomainを渡すためにキャッシュする
  final EventDomain? cachedEvent;

  const EventDetailLoaded({
    required this.projection,
    required this.draft,
    this.delegate,
    this.isSaving = false,
    this.saveErrorMessage,
    TopicConfig? topicConfig,
    this.cachedEvent,
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

  EventDetailLoaded copyWith({
    EventDetailProjection? projection,
    EventDetailDraft? draft,
    EventDetailDelegate? delegate,
    bool? isSaving,
    String? saveErrorMessage,
    TopicConfig? topicConfig,
    EventDomain? cachedEvent,
  }) {
    return EventDetailLoaded(
      projection: projection ?? this.projection,
      draft: draft ?? this.draft,
      delegate: delegate,
      isSaving: isSaving ?? this.isSaving,
      saveErrorMessage: saveErrorMessage,
      topicConfig: topicConfig ?? this.topicConfig,
      cachedEvent: cachedEvent ?? this.cachedEvent,
    );
  }

  @override
  List<Object?> get props => [projection, draft, delegate, isSaving, saveErrorMessage, topicConfig, cachedEvent];
}

class EventDetailError extends EventDetailState {
  final String message;
  const EventDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
