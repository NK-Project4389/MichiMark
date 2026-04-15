import 'package:flutter/material.dart';
import '../../../domain/transaction/event/event_domain.dart';
import '../../../domain/topic/topic_domain.dart';
import '../projection/dashboard_projection.dart';
import '../projection/visit_work_dashboard_projection.dart';

class VisitWorkDashboardAdapter {
  static VisitWorkDashboardProjection toProjection(
    List<EventDomain> events,
    DateRange period,
  ) {
    // visitWorkイベントのみ対象
    final filtered = events.where((e) {
      final topic = e.topic;
      if (topic == null) return false;
      return topic.topicType == TopicType.visitWork;
    }).toList();

    // 7日分の日付リストを生成
    final days = List.generate(7, (i) {
      final d = period.start.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });

    // 日別集計データ構造
    final Map<DateTime, _DayVisitData> dayDataMap = {
      for (final d in days) d: _DayVisitData(),
    };

    // 全アクション時間の集計（actionName → 総時間[hours]）
    final Map<String, double> totalHoursByAction = {};
    double totalDistanceKm = 0.0;
    int totalRevenueYen = 0;
    int workDaysCount = 0;

    for (final event in filtered) {
      // actionTimeLogsから作業時間を集計
      final logs = event.actionTimeLogs.where((l) => !l.isDeleted).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // logをペアリングして作業時間を計算
      // start/end ペアをアクションIDでグルーピング
      final Map<String, List<DateTime>> actionTimestamps = {};
      for (final log in logs) {
        final logDay = DateTime(
          log.timestamp.year,
          log.timestamp.month,
          log.timestamp.day,
        );
        if (!days.contains(logDay)) continue;
        actionTimestamps.putIfAbsent(log.actionId, () => []).add(log.timestamp);
      }

      // 各アクションの時間を単純に最初と最後のdiff÷2として近似
      // (より正確なペアリングはActionTimeDomainの仕様次第だが、ここでは合計で算出)
      for (final entry in actionTimestamps.entries) {
        final timestamps = entry.value;
        if (timestamps.length >= 2) {
          final durationHours =
              timestamps.last.difference(timestamps.first).inMinutes / 60.0;
          totalHoursByAction.update(
            entry.key,
            (v) => v + durationHours,
            ifAbsent: () => durationHours,
          );

          // 日別データへの追加（先頭のタイムスタンプの日に集計）
          final firstDay = DateTime(
            timestamps.first.year,
            timestamps.first.month,
            timestamps.first.day,
          );
          if (dayDataMap.containsKey(firstDay)) {
            dayDataMap[firstDay]!.workHoursByAction.update(
              entry.key,
              (v) => v + durationHours,
              ifAbsent: () => durationHours,
            );
          }
        }
      }

      // 売上: payments合計
      for (final payment in event.payments) {
        if (payment.isDeleted) continue;
        // eventのmarkLinkDateが期間内かどうかを判定
        // eventのcreatedAtで期間判定
        final eventDay = DateTime(
          event.createdAt.year,
          event.createdAt.month,
          event.createdAt.day,
        );
        if (days.contains(eventDay)) {
          dayDataMap[eventDay]!.revenueYen += payment.paymentAmount;
          totalRevenueYen += payment.paymentAmount;
        }
      }

      // 走行距離: markLinksのlinkタイプのdistanceValue
      for (final ml in event.markLinks) {
        if (ml.isDeleted) continue;
        final mlDay = DateTime(
          ml.markLinkDate.year,
          ml.markLinkDate.month,
          ml.markLinkDate.day,
        );
        if (!days.contains(mlDay)) continue;
        final dist = ml.distanceValue;
        if (dist != null) {
          totalDistanceKm += dist.toDouble();
        }
      }
    }

    // 作業日数カウント（workHoursByActionが存在する日）
    for (final day in days) {
      if (dayDataMap[day]!.workHoursByAction.isNotEmpty) {
        workDaysCount++;
      }
    }

    // DailyEntry生成
    final dailyEntries = days.map((day) {
      final data = dayDataMap[day]!;
      return DailyVisitWorkEntry(
        date: day,
        workHoursByAction: Map.unmodifiable(data.workHoursByAction),
        revenueYen: data.revenueYen,
        dateLabel: '${day.month}/${day.day}',
      );
    }).toList();

    // workBreakdown（ドーナツグラフ用）
    final totalHours = totalHoursByAction.values.fold(0.0, (a, b) => a + b);
    final colors = _generateColors(totalHoursByAction.length);
    final workBreakdown = <WorkBreakdownEntry>[];
    var colorIndex = 0;
    for (final entry in totalHoursByAction.entries) {
      final pct = totalHours > 0 ? (entry.value / totalHours * 100) : 0.0;
      workBreakdown.add(WorkBreakdownEntry(
        actionName: entry.key,
        hours: entry.value,
        percentage: pct,
        color: colors[colorIndex % colors.length],
      ));
      colorIndex++;
    }

    // KPIラベル
    final totalWorkHours = totalHours;
    final totalH = totalWorkHours.floor();
    final totalM = ((totalWorkHours - totalH) * 60).round();
    final totalWorkTimeLabel = totalWorkHours > 0
        ? '$totalH時間$totalM分'
        : '---';

    final totalRevenueLabel = totalRevenueYen > 0
        ? '¥${_formatYen(totalRevenueYen)}'
        : '---';

    String hourlyRateLabel = '---';
    if (totalRevenueYen > 0 && totalWorkHours > 0) {
      final rate = (totalRevenueYen / totalWorkHours).round();
      hourlyRateLabel = '¥${_formatYen(rate)} / h';
    }

    final utilizationRate = (workDaysCount / 7 * 100).round();
    final utilizationRateLabel = '$utilizationRate%';

    final totalDistanceLabel = totalDistanceKm > 0
        ? '${totalDistanceKm.toStringAsFixed(1)} km'
        : '--- km';

    // workTimeBreakdownLabels
    final workTimeBreakdownLabels = <String, String>{};
    for (final entry in totalHoursByAction.entries) {
      final h = entry.value.floor();
      final m = ((entry.value - h) * 60).round();
      workTimeBreakdownLabels[entry.key] = '$h時間$m分';
    }

    return VisitWorkDashboardProjection(
      dailyEntries: dailyEntries,
      workBreakdown: workBreakdown,
      totalWorkTimeLabel: totalWorkTimeLabel,
      totalRevenueLabel: totalRevenueLabel,
      hourlyRateLabel: hourlyRateLabel,
      utilizationRateLabel: utilizationRateLabel,
      totalDistanceLabel: totalDistanceLabel,
      workTimeBreakdownLabels: workTimeBreakdownLabels,
    );
  }

  static List<Color> _generateColors(int count) {
    const base = [
      Color(0xFF29A8D4),
      Color(0xFF2E9E6B),
      Color(0xFFE07B39),
      Color(0xFF7B5CC4),
      Color(0xFFD94F4F),
      Color(0xFFC4A43A),
      Color(0xFF3D65C4),
      Color(0xFFC4497A),
    ];
    if (count == 0) return base;
    return List.generate(count, (i) => base[i % base.length]);
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

class _DayVisitData {
  Map<String, double> workHoursByAction = {};
  int revenueYen = 0;
}
