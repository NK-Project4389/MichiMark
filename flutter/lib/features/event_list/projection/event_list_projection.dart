import 'package:equatable/equatable.dart';

/// イベント一覧画面の表示用データ
class EventListProjection extends Equatable {
  final List<EventSummaryItemProjection> events;

  const EventListProjection({required this.events});

  bool get isEmpty => events.isEmpty;

  @override
  List<Object?> get props => [events];
}

/// イベント一覧の各行に表示するデータ
class EventSummaryItemProjection extends Equatable {
  final String id;
  final String eventName;

  /// 最初のマーク/リンクの日付（フォーマット済み文字列）
  final String displayFromDate;

  /// 最後のマーク/リンクの日付（フォーマット済み文字列）。未実装時は空文字
  final String displayToDate;

  const EventSummaryItemProjection({
    required this.id,
    required this.eventName,
    required this.displayFromDate,
    required this.displayToDate,
  });

  @override
  List<Object?> get props => [id, eventName, displayFromDate, displayToDate];
}
