import 'package:equatable/equatable.dart';
import '../../basic_info/draft/basic_info_draft.dart';
import '../draft/event_detail_draft.dart';

sealed class EventDetailEvent extends Equatable {
  const EventDetailEvent();
}

/// 画面が表示されたとき
class EventDetailStarted extends EventDetailEvent {
  final String eventId;
  const EventDetailStarted(this.eventId);

  @override
  List<Object?> get props => [eventId];
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

/// 保存ボタンが押されたとき（全タブ一括保存）
class EventDetailSaveRequested extends EventDetailEvent {
  final String eventId;
  final BasicInfoDraft basicInfoDraft;
  const EventDetailSaveRequested({
    required this.eventId,
    required this.basicInfoDraft,
  });

  @override
  List<Object?> get props => [eventId, basicInfoDraft];
}
