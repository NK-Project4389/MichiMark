import 'package:equatable/equatable.dart';

class DailyMovingCostEntry extends Equatable {
  final DateTime date;
  final double distanceKm;
  final int? costYen;
  final int cumulativeCostYen;
  final String dateLabel;

  const DailyMovingCostEntry({
    required this.date,
    required this.distanceKm,
    this.costYen,
    required this.cumulativeCostYen,
    required this.dateLabel,
  });

  @override
  List<Object?> get props => [date, distanceKm, costYen, cumulativeCostYen, dateLabel];
}

class MovingCostDashboardProjection extends Equatable {
  final List<DailyMovingCostEntry> dailyEntries;
  final String totalDistanceLabel;
  final String totalCostLabel;
  final String avgFuelEfficiencyLabel;
  final bool hasFuelData;

  const MovingCostDashboardProjection({
    required this.dailyEntries,
    required this.totalDistanceLabel,
    required this.totalCostLabel,
    required this.avgFuelEfficiencyLabel,
    required this.hasFuelData,
  });

  @override
  List<Object?> get props => [
        dailyEntries,
        totalDistanceLabel,
        totalCostLabel,
        avgFuelEfficiencyLabel,
        hasFuelData,
      ];
}
