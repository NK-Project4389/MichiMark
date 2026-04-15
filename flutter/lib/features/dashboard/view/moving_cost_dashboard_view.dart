import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../projection/moving_cost_dashboard_projection.dart';

class MovingCostDashboardView extends StatelessWidget {
  final MovingCostDashboardProjection projection;

  const MovingCostDashboardView({super.key, required this.projection});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChart(context),
          const SizedBox(height: 24),
          _buildKpiCards(context),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final entries = projection.dailyEntries;
    final maxDistance = entries.fold(0.0, (m, e) => e.distanceKm > m ? e.distanceKm : m);
    final maxCost = entries.fold(0, (m, e) => e.cumulativeCostYen > m ? e.cumulativeCostYen : m);

    return SizedBox(
      key: const Key('moving_cost_dashboard_chart'),
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxDistance > 0 ? maxDistance * 1.2 : 10,
          barGroups: entries.asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: entry.distanceKm,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: maxCost > 0,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (maxCost == 0) return const SizedBox.shrink();
                  final costValue = (value / 200 * maxCost).round();
                  return Text(
                    '¥$costValue',
                    style: const TextStyle(fontSize: 9),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    entries[idx].dateLabel,
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
        ),
      ),
    );
  }

  Widget _buildKpiCards(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                widgetKey: const Key('moving_cost_total_distance_label'),
                label: '総走行距離',
                value: projection.totalDistanceLabel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                widgetKey: const Key('moving_cost_total_cost_label'),
                label: '総コスト',
                value: projection.totalCostLabel,
              ),
            ),
          ],
        ),
        if (projection.hasFuelData) ...[
          const SizedBox(height: 12),
          _KpiCard(
            widgetKey: const Key('moving_cost_avg_fuel_label'),
            label: '平均燃費',
            value: projection.avgFuelEfficiencyLabel,
          ),
        ],
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final Key widgetKey;
  final String label;
  final String value;

  const _KpiCard({
    required this.widgetKey,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              key: widgetKey,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
