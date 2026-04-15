import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_domain.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
}

/// 画面初期化（タブ表示時）
class DashboardInitialized extends DashboardEvent {
  const DashboardInitialized();

  @override
  List<Object?> get props => [];
}

/// トピックチップ選択
class DashboardTopicSelected extends DashboardEvent {
  final TopicType topic;

  const DashboardTopicSelected(this.topic);

  @override
  List<Object?> get props => [topic];
}

/// 旅費カレンダーの月変更
class DashboardMonthChanged extends DashboardEvent {
  final DateTime month;

  const DashboardMonthChanged(this.month);

  @override
  List<Object?> get props => [month];
}

/// 旅費カレンダーのイベントバッジタップ
class DashboardTravelEventTapped extends DashboardEvent {
  final String eventId;

  const DashboardTravelEventTapped(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// Delegateを消費済みとしてリセット
class DashboardDelegateConsumed extends DashboardEvent {
  const DashboardDelegateConsumed();

  @override
  List<Object?> get props => [];
}
