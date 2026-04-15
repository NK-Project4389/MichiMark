import '../../../domain/transaction/event/event_domain.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../projection/dashboard_projection.dart';
import '../projection/moving_cost_dashboard_projection.dart';

class MovingCostDashboardAdapter {
  static MovingCostDashboardProjection toProjection(
    List<EventDomain> events,
    DateRange period,
  ) {
    // period内のmovingCost / movingCostEstimatedイベントを絞り込み
    final filtered = events.where((e) {
      final topic = e.topic;
      if (topic == null) return true; // nullはmovingCost相当
      return topic.topicType == TopicType.movingCost ||
          topic.topicType == TopicType.movingCostEstimated;
    }).toList();

    // 7日分の日付リストを生成
    final days = List.generate(7, (i) {
      final d = period.start.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });

    // 日別集計
    int cumulativeCost = 0;
    int totalGasPrice = 0;
    int totalGasQuantity = 0; // 0.1L単位
    double totalDistanceKm = 0.0;
    bool hasFuelData = false;

    // 全イベントの集計（period内イベントから日別データ）
    // まず期間内の全Linkの走行距離とMarkの給油情報をイベントから抽出
    // eventsはcreatedAt基準ではなく、MarkLinkDateで絞り込む
    final Map<DateTime, _DayData> dayDataMap = {
      for (final d in days) d: _DayData(),
    };

    for (final event in filtered) {
      for (final ml in event.markLinks) {
        if (ml.isDeleted) continue;
        final mlDate = DateTime(
          ml.markLinkDate.year,
          ml.markLinkDate.month,
          ml.markLinkDate.day,
        );
        if (!dayDataMap.containsKey(mlDate)) continue;

        if (ml.markLinkType == MarkOrLink.link) {
          final dist = ml.distanceValue;
          if (dist != null) {
            dayDataMap[mlDate]!.distanceKm += dist.toDouble();
            totalDistanceKm += dist.toDouble();
          }
        }
        if (ml.isFuel) {
          final price = ml.gasPrice;
          final qty = ml.gasQuantity;
          if (price != null) {
            dayDataMap[mlDate]!.costYen = (dayDataMap[mlDate]!.costYen ?? 0) + price;
            totalGasPrice += price;
            hasFuelData = true;
          }
          if (qty != null) {
            totalGasQuantity += qty;
          }
        }
      }
    }

    // DailyEntry生成・累積コスト計算
    final entries = <DailyMovingCostEntry>[];
    for (final day in days) {
      final data = dayDataMap[day]!;
      if (data.costYen != null) {
        cumulativeCost += data.costYen!;
      }
      entries.add(DailyMovingCostEntry(
        date: day,
        distanceKm: data.distanceKm,
        costYen: data.costYen,
        cumulativeCostYen: cumulativeCost,
        dateLabel: '${day.month}/${day.day}',
      ));
    }

    // KPIラベル生成
    final totalDistanceLabel = totalDistanceKm > 0
        ? '${totalDistanceKm.toStringAsFixed(1)} km'
        : '--- km';

    final totalCostLabel = hasFuelData
        ? '¥${_formatYen(totalGasPrice)}'
        : '---';

    // 平均燃費: 総走行距離 / 総給油量(L)
    String avgFuelEfficiencyLabel = '---';
    if (hasFuelData && totalGasQuantity > 0 && totalDistanceKm > 0) {
      final totalLiters = totalGasQuantity / 10.0;
      final kmPerL = totalDistanceKm / totalLiters;
      avgFuelEfficiencyLabel = '${kmPerL.toStringAsFixed(1)} km/L';
    }

    return MovingCostDashboardProjection(
      dailyEntries: entries,
      totalDistanceLabel: totalDistanceLabel,
      totalCostLabel: totalCostLabel,
      avgFuelEfficiencyLabel: avgFuelEfficiencyLabel,
      hasFuelData: hasFuelData,
    );
  }

  static String _formatYen(int yen) {
    final s = yen.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _DayData {
  double distanceKm = 0.0;
  int? costYen;
}
