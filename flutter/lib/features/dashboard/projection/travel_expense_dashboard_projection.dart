import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TravelEventCalendarEntry extends Equatable {
  final DateTime date;
  final String eventId;
  final String eventTitle;
  final Color topicColor;

  const TravelEventCalendarEntry({
    required this.date,
    required this.eventId,
    required this.eventTitle,
    required this.topicColor,
  });

  @override
  List<Object?> get props => [date, eventId, eventTitle, topicColor];
}

class TopRouteEntry extends Equatable {
  final String routeName;
  final int usageCount;
  final double totalDistanceKm;

  const TopRouteEntry({
    required this.routeName,
    required this.usageCount,
    required this.totalDistanceKm,
  });

  @override
  List<Object?> get props => [routeName, usageCount, totalDistanceKm];
}

class TravelExpenseDashboardProjection extends Equatable {
  final DateTime displayMonth;
  final List<TravelEventCalendarEntry> calendarEntries;
  final String tripCountLabel;
  final String spotCountLabel;
  final String totalExpenseLabel;
  final List<TopRouteEntry> topRoutes;

  const TravelExpenseDashboardProjection({
    required this.displayMonth,
    required this.calendarEntries,
    required this.tripCountLabel,
    required this.spotCountLabel,
    required this.totalExpenseLabel,
    required this.topRoutes,
  });

  @override
  List<Object?> get props => [
        displayMonth,
        calendarEntries,
        tripCountLabel,
        spotCountLabel,
        totalExpenseLabel,
        topRoutes,
      ];
}
