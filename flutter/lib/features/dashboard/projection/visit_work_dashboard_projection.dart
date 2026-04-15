import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DailyVisitWorkEntry extends Equatable {
  final DateTime date;
  final Map<String, double> workHoursByAction;
  final int revenueYen;
  final String dateLabel;

  const DailyVisitWorkEntry({
    required this.date,
    required this.workHoursByAction,
    required this.revenueYen,
    required this.dateLabel,
  });

  @override
  List<Object?> get props => [date, workHoursByAction, revenueYen, dateLabel];
}

class WorkBreakdownEntry extends Equatable {
  final String actionName;
  final double hours;
  final double percentage;
  final Color color;

  const WorkBreakdownEntry({
    required this.actionName,
    required this.hours,
    required this.percentage,
    required this.color,
  });

  @override
  List<Object?> get props => [actionName, hours, percentage, color];
}

class VisitWorkDashboardProjection extends Equatable {
  final List<DailyVisitWorkEntry> dailyEntries;
  final List<WorkBreakdownEntry> workBreakdown;
  final String totalWorkTimeLabel;
  final String totalRevenueLabel;
  final String hourlyRateLabel;
  final String utilizationRateLabel;
  final String totalDistanceLabel;
  final Map<String, String> workTimeBreakdownLabels;

  const VisitWorkDashboardProjection({
    required this.dailyEntries,
    required this.workBreakdown,
    required this.totalWorkTimeLabel,
    required this.totalRevenueLabel,
    required this.hourlyRateLabel,
    required this.utilizationRateLabel,
    required this.totalDistanceLabel,
    required this.workTimeBreakdownLabels,
  });

  @override
  List<Object?> get props => [
        dailyEntries,
        workBreakdown,
        totalWorkTimeLabel,
        totalRevenueLabel,
        hourlyRateLabel,
        utilizationRateLabel,
        totalDistanceLabel,
        workTimeBreakdownLabels,
      ];
}
