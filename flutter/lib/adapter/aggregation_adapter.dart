import 'package:intl/intl.dart';
import '../domain/aggregation/aggregation_filter.dart';
import '../domain/aggregation/aggregation_result.dart';
import '../features/aggregation/projection/aggregation_projection.dart';

/// AggregationResult → AggregationProjection の変換を担当。
/// 表示文字列フォーマットロジックをここに集約する。
class AggregationAdapter {
  AggregationAdapter._();

  static final _currencyFormat = NumberFormat('#,###');

  static AggregationProjection toProjection(
    AggregationResult result,
    AggregationFilter filter,
  ) {
    return AggregationProjection(
      eventCountLabel: '${result.eventCount}件',
      movingTimeLabel: _formatDuration(result.movingTime),
      workingTimeLabel: _formatDuration(result.workingTime),
      breakTimeLabel: _formatDuration(result.breakTime),
      totalDistanceLabel: '${result.totalDistance}km',
      totalGasPriceLabel: result.totalGasPrice != null
          ? '${_currencyFormat.format(result.totalGasPrice!)}円'
          : '---',
      totalPaymentLabel: result.totalPayment != null
          ? '${_currencyFormat.format(result.totalPayment!)}円'
          : '---',
      filterSummaryLabel: _buildFilterSummary(filter),
    );
  }

  static String _formatDuration(Duration? duration) {
    if (duration == null) return '---';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}分';
    return '${hours}時間${minutes}分';
  }

  static String _buildFilterSummary(AggregationFilter filter) {
    final parts = <String>[];

    parts.add(switch (filter.dateRange) {
      ThisMonth() => '今月',
      LastMonth() => '先月',
      CustomRange(:final startDate, :final endDate) =>
        '${startDate.month}/${startDate.day}〜${endDate.month}/${endDate.day}',
    });

    if (filter.tagIds.isNotEmpty) {
      parts.add('タグ: ${filter.tagIds.length}件');
    }
    if (filter.memberIds.isNotEmpty) {
      parts.add('メンバー: ${filter.memberIds.length}件');
    }
    if (filter.transId != null) {
      parts.add('交通手段指定');
    }
    if (filter.topicId != null) {
      parts.add('Topic指定');
    }

    return parts.join(' / ');
  }
}
