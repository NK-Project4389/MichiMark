import '../domain/aggregation/aggregation_result.dart';
import '../domain/visit_work/visit_work_aggregation.dart';
import '../domain/visit_work/visit_work_timeline.dart';

/// AggregationResult + VisitWorkTimeline → VisitWorkAggregation に変換する
class VisitWorkAggregationAdapter {
  VisitWorkAggregationAdapter._();

  static VisitWorkAggregation fromResults({
    required AggregationResult aggregation,
    required VisitWorkTimeline timeline,
  }) {
    return VisitWorkAggregation(
      movingDuration: aggregation.movingTime ?? Duration.zero,
      stayingDuration: aggregation.waitingTime ?? Duration.zero,
      workingDuration: aggregation.workingTime ?? Duration.zero,
      breakDuration: aggregation.breakTime ?? Duration.zero,
      onSiteDuration: timeline.onSiteDuration,
      revenue: aggregation.totalPayment,
      isOngoing: timeline.isOngoing,
    );
  }
}
