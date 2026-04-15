import 'package:flutter/material.dart';
import '../../../domain/transaction/event/event_domain.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../projection/travel_expense_dashboard_projection.dart';

class TravelExpenseDashboardAdapter {
  static TravelExpenseDashboardProjection toProjection(
    List<EventDomain> events,
    DateTime displayMonth,
  ) {
    // travelExpenseイベントのみ対象
    final filtered = events.where((e) {
      final topic = e.topic;
      if (topic == null) return false;
      return topic.topicType == TopicType.travelExpense;
    }).toList();

    // displayMonth の月内イベントを抽出
    final monthStart = DateTime(displayMonth.year, displayMonth.month, 1);
    final monthEnd = DateTime(displayMonth.year, displayMonth.month + 1, 1)
        .subtract(const Duration(seconds: 1));

    final monthEvents = filtered.where((e) {
      // イベントの日付: markLinksの先頭markLinkDateを代表日として使用
      // markLinksがない場合はcreatedAtを使用
      final representativeDate = _getRepresentativeDate(e);
      return representativeDate != null &&
          !representativeDate.isBefore(monthStart) &&
          !representativeDate.isAfter(monthEnd);
    }).toList();

    // calendarEntries生成
    final calendarEntries = <TravelEventCalendarEntry>[];
    for (final event in monthEvents) {
      final date = _getRepresentativeDate(event);
      if (date == null) continue;
      final topic = event.topic;
      final color = topic != null
          ? TopicConfig.fromTopicType(topic.topicType).themeColor.primaryColor
          : const Color(0xFF9E9E9E);
      final title = event.eventName.length > 8
          ? event.eventName.substring(0, 8)
          : event.eventName;
      calendarEntries.add(TravelEventCalendarEntry(
        date: DateTime(date.year, date.month, date.day),
        eventId: event.id,
        eventTitle: title,
        topicColor: color,
      ));
    }

    // KPI集計（displayMonth内）
    final tripCount = monthEvents.length;

    // スポット数: markLinksのMarkの件数合計
    int spotCount = 0;
    int totalExpense = 0;
    for (final event in monthEvents) {
      for (final ml in event.markLinks) {
        if (ml.isDeleted) continue;
        spotCount++;
      }
      for (final payment in event.payments) {
        if (payment.isDeleted) continue;
        totalExpense += payment.paymentAmount;
      }
    }

    // topRoutes: データ不足時は空リスト（Widgetでは非表示）
    final topRoutes = <TopRouteEntry>[];

    final tripCountLabel = '$tripCount 件';
    final spotCountLabel = '$spotCount か所';
    final totalExpenseLabel = totalExpense > 0
        ? '¥${_formatYen(totalExpense)}'
        : '¥0';

    return TravelExpenseDashboardProjection(
      displayMonth: displayMonth,
      calendarEntries: calendarEntries,
      tripCountLabel: tripCountLabel,
      spotCountLabel: spotCountLabel,
      totalExpenseLabel: totalExpenseLabel,
      topRoutes: topRoutes,
    );
  }

  static DateTime? _getRepresentativeDate(EventDomain event) {
    final validMarkLinks = event.markLinks.where((ml) => !ml.isDeleted).toList();
    if (validMarkLinks.isNotEmpty) {
      return validMarkLinks.first.markLinkDate;
    }
    return event.createdAt;
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
