import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_domain.dart';
import '../draft/event_detail_draft.dart';

sealed class EventDetailEvent extends Equatable {
  const EventDetailEvent();
}

/// 画面が表示されたとき
class EventDetailStarted extends EventDetailEvent {
  final String eventId;

  /// 新規作成時のみ使用。既存イベントの場合は null。
  final TopicType? initialTopicType;

  const EventDetailStarted(this.eventId, {this.initialTopicType});

  @override
  List<Object?> get props => [eventId, initialTopicType];
}

/// タブが選択されたとき
class EventDetailTabSelected extends EventDetailEvent {
  final EventDetailTab tab;
  const EventDetailTabSelected(this.tab);

  @override
  List<Object?> get props => [tab];
}

/// 戻るボタンが押されたとき
class EventDetailDismissPressed extends EventDetailEvent {
  const EventDetailDismissPressed();

  @override
  List<Object?> get props => [];
}

/// マーク詳細を開く要求
class EventDetailOpenMarkRequested extends EventDetailEvent {
  final String markLinkId;
  const EventDetailOpenMarkRequested(this.markLinkId);

  @override
  List<Object?> get props => [markLinkId];
}

/// リンク詳細を開く要求
class EventDetailOpenLinkRequested extends EventDetailEvent {
  final String markLinkId;
  const EventDetailOpenLinkRequested(this.markLinkId);

  @override
  List<Object?> get props => [markLinkId];
}

/// 支払詳細を開く要求
class EventDetailOpenPaymentRequested extends EventDetailEvent {
  final String paymentId;
  const EventDetailOpenPaymentRequested(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

/// マーク/リンク追加要求
class EventDetailAddMarkLinkRequested extends EventDetailEvent {
  const EventDetailAddMarkLinkRequested();

  @override
  List<Object?> get props => [];
}

/// BasicInfoSavedDelegate後にcachedEventを更新する要求
class EventDetailCachedEventUpdateRequested extends EventDetailEvent {
  const EventDetailCachedEventUpdateRequested();

  @override
  List<Object?> get props => [];
}

/// 削除アイコンがタップされたとき
class EventDetailDeleteButtonPressed extends EventDetailEvent {
  const EventDetailDeleteButtonPressed();

  @override
  List<Object?> get props => [];
}

/// 確認ダイアログで「削除」がタップされたとき
class EventDetailDeleteConfirmed extends EventDetailEvent {
  const EventDetailDeleteConfirmed();

  @override
  List<Object?> get props => [];
}

/// 削除確認ダイアログが閉じられたとき（キャンセル時のフラグリセット）
class EventDetailDeleteDialogDismissed extends EventDetailEvent {
  const EventDetailDeleteDialogDismissed();

  @override
  List<Object?> get props => [];
}

/// delegateを消費済みにする（nullリセット）
class EventDetailDelegateConsumed extends EventDetailEvent {
  const EventDetailDelegateConsumed();

  @override
  List<Object?> get props => [];
}

/// 子Bloc（BasicInfo・MichiInfo・PaymentInfo）が保存完了したとき
/// isSavedAtLeastOnce を true にするために発火する
class EventDetailChildSaved extends EventDetailEvent {
  const EventDetailChildSaved();

  @override
  List<Object?> get props => [];
}
