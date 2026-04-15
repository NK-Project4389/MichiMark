import 'package:equatable/equatable.dart';
import '../action_time/action_state.dart';
import 'visit_work_segment.dart';

/// インタープリターの出力。複数の VisitWorkSegment の時系列リスト。
class VisitWorkTimeline extends Equatable {
  /// 時系列順のセグメントリスト
  final List<VisitWorkSegment> segments;

  /// 最後のアクションが「出発」以外 = 進行中
  final bool isOngoing;

  const VisitWorkTimeline({
    required this.segments,
    required this.isOngoing,
  });

  /// タイムライン全体の開始時刻（最初のセグメントの from）
  DateTime? get startTime => segments.isEmpty ? null : segments.first.from;

  /// タイムライン全体の終了時刻（isOngoing == true なら null）
  DateTime? get endTime => isOngoing ? null : segments.last.to;

  /// 現地滞在開始（最初の「到着」セグメントの from）
  /// moving → waiting に遷移した最初のタイミング
  DateTime? get arrivedAt {
    for (final seg in segments) {
      if (seg.state == ActionState.waiting) return seg.from;
    }
    return null;
  }

  /// 現地滞在終了（最後の「出発」前の区切り）
  /// waiting → moving に遷移した最後のタイミング
  DateTime? get departedAt {
    if (isOngoing) return null;
    for (final seg in segments.reversed) {
      if (seg.state == ActionState.moving) return seg.from;
    }
    return null;
  }

  /// 在現地時間（到着〜出発の合計時間）
  Duration? get onSiteDuration {
    final a = arrivedAt;
    final d = departedAt;
    if (a == null) return null;
    final end = d ?? DateTime.now();
    return end.difference(a);
  }

  @override
  List<Object?> get props => [segments, isOngoing];
}
