import 'package:intl/intl.dart';
import '../domain/aggregation/aggregation_result.dart';
import '../domain/transaction/event/event_domain.dart';
import '../features/overview/projection/moving_cost_overview_projection.dart';
import 'moving_cost_balance_adapter.dart';
import 'travel_expense_overview_adapter.dart';

/// AggregationResult → MovingCostOverviewProjection の変換を担当。
/// 表示文字列フォーマットロジックをここに集約する。
/// BLoC内に表示文字列フォーマットを記述しない。
class EventDetailOverviewAdapter {
  EventDetailOverviewAdapter._();

  static final _currencyFormat = NumberFormat('#,###');

  static MovingCostOverviewProjection toMovingCostProjection(
    AggregationResult result, {
    EventDomain? event,
  }) {
    // 実績ガソリン代がない場合は、燃費推定モードとして推計値を計算する
    // 推計: totalDistance(km) / (kmPerGas/10)(km/L) * pricePerGas(円/L)
    int? effectiveGasPrice = result.totalGasPrice;
    if (effectiveGasPrice == null && event != null) {
      final km = event.kmPerGas;
      final price = event.pricePerGas;
      if (km != null && km > 0 && price != null) {
        effectiveGasPrice = (result.totalDistance / (km / 10.0) * price).round();
      }
    }

    // 収支バランス計算
    final memberBalances = event != null
        ? MovingCostBalanceAdapter.toBalances(
            event,
            event.topic?.topicType,
          )
        : <MemberBalanceProjection>[];

    return MovingCostOverviewProjection(
      movingTimeLabel: _formatDuration(result.movingTime),
      workingTimeLabel: _formatDuration(result.workingTime),
      breakTimeLabel: _formatDuration(result.breakTime),
      waitingTimeLabel: _formatDuration(result.waitingTime),
      totalDistanceLabel: '${result.totalDistance}km',
      totalGasQuantityLabel: result.totalGasQuantity != null
          ? '${(result.totalGasQuantity! / 10).toStringAsFixed(1)}L'
          : '---',
      totalGasPriceLabel: effectiveGasPrice != null
          ? '${_currencyFormat.format(effectiveGasPrice)}円'
          : '---',
      totalPaymentLabel: result.totalPayment != null
          ? '${_currencyFormat.format(result.totalPayment!)}円'
          : '---',
      hasFuelData: result.totalGasQuantity != null,
      memberBalances: memberBalances,
    );
  }

  static String _formatDuration(Duration? duration) {
    if (duration == null) return '---';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}分';
    return '${hours}時間${minutes}分';
  }
}
