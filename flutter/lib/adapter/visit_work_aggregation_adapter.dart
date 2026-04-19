import '../domain/aggregation/aggregation_result.dart';
import '../domain/transaction/payment/payment_domain.dart';
import '../domain/transaction/payment/payment_type.dart';
import '../domain/visit_work/visit_work_aggregation.dart';
import '../domain/visit_work/visit_work_timeline.dart';

/// AggregationResult + VisitWorkTimeline → VisitWorkAggregation に変換する
class VisitWorkAggregationAdapter {
  VisitWorkAggregationAdapter._();

  static VisitWorkAggregation fromResults({
    required AggregationResult aggregation,
    required VisitWorkTimeline timeline,
    required List<PaymentDomain> payments,
  }) {
    // revenue 種別のみの合計を算出（論理削除除外済み想定）
    final revenueTotal = payments
        .where((p) => !p.isDeleted && p.paymentType == PaymentType.revenue)
        .fold<int>(0, (sum, p) => sum + p.paymentAmount);

    return VisitWorkAggregation(
      movingDuration: aggregation.movingTime ?? Duration.zero,
      stayingDuration: aggregation.waitingTime ?? Duration.zero,
      workingDuration: aggregation.workingTime ?? Duration.zero,
      breakDuration: aggregation.breakTime ?? Duration.zero,
      onSiteDuration: timeline.onSiteDuration,
      revenue: revenueTotal,
      isOngoing: timeline.isOngoing,
    );
  }
}
