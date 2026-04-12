import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/topic/topic_theme_color.dart';
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

/// イベント削除完了後に一覧へ戻る
class EventDetailDeletedDelegate extends EventDetailDelegate {
  const EventDetailDeletedDelegate();

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
  final TopicConfig topicConfig;
  /// OverviewBlocにEventDomainを渡すためにキャッシュする
  final EventDomain? cachedEvent;
  /// Topicのテーマカラー。Topic未設定時はnull（デフォルトAppBar表示）（REQ-008）
  final TopicThemeColor? topicThemeColor;
  /// Topicの日本語表示名。Topic未設定時はnull（REQ-008）
  final String? topicDisplayName;
  /// 削除確認ダイアログの表示フラグ。trueのときPageが確認ダイアログを表示する
  final bool showDeleteConfirmDialog;

  const EventDetailLoaded({
    required this.projection,
    required this.draft,
    this.delegate,
    TopicConfig? topicConfig,
    this.cachedEvent,
    this.topicThemeColor,
    this.topicDisplayName,
    this.showDeleteConfirmDialog = false,
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

  EventDetailLoaded copyWith({
    EventDetailProjection? projection,
    EventDetailDraft? draft,
    EventDetailDelegate? delegate,
    TopicConfig? topicConfig,
    EventDomain? cachedEvent,
    TopicThemeColor? topicThemeColor,
    String? topicDisplayName,
    bool clearTopicThemeColor = false,
    bool clearTopicDisplayName = false,
    bool? showDeleteConfirmDialog,
  }) {
    return EventDetailLoaded(
      projection: projection ?? this.projection,
      draft: draft ?? this.draft,
      delegate: delegate,
      topicConfig: topicConfig ?? this.topicConfig,
      cachedEvent: cachedEvent ?? this.cachedEvent,
      topicThemeColor: clearTopicThemeColor ? null : (topicThemeColor ?? this.topicThemeColor),
      topicDisplayName: clearTopicDisplayName ? null : (topicDisplayName ?? this.topicDisplayName),
      showDeleteConfirmDialog: showDeleteConfirmDialog ?? this.showDeleteConfirmDialog,
    );
  }

  @override
  List<Object?> get props => [
        projection,
        draft,
        delegate,
        topicConfig,
        cachedEvent,
        topicThemeColor,
        topicDisplayName,
        showDeleteConfirmDialog,
      ];
}

class EventDetailError extends EventDetailState {
  final String message;
  const EventDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
