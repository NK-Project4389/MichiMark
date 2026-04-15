import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../projection/visit_work_dashboard_projection.dart';

class VisitWorkDashboardView extends StatelessWidget {
  final VisitWorkDashboardProjection projection;

  const VisitWorkDashboardView({super.key, required this.projection});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComboChart(context),
          const SizedBox(height: 24),
          _buildDonutChart(context),
          const SizedBox(height: 24),
          _buildKpiCards(context),
        ],
      ),
    );
  }

  Widget _buildComboChart(BuildContext context) {
    final entries = projection.dailyEntries;
    final allActions = <String>{};
    for (final e in entries) {
      allActions.addAll(e.workHoursByAction.keys);
    }
    final actionList = allActions.toList();

    final maxHours = entries.fold(0.0, (m, e) {
      final total = e.workHoursByAction.values.fold(0.0, (a, b) => a + b);
      return total > m ? total : m;
    });

    final colorMap = <String, Color>{};
    final baseColors = [
      const Color(0xFF29A8D4),
      const Color(0xFF2E9E6B),
      const Color(0xFFE07B39),
      const Color(0xFF7B5CC4),
      const Color(0xFFD94F4F),
    ];
    for (var i = 0; i < actionList.length; i++) {
      colorMap[actionList[i]] = baseColors[i % baseColors.length];
    }

    return SizedBox(
      key: const Key('visit_work_dashboard_combo_chart'),
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxHours > 0 ? maxHours * 1.2 : 8,
          barGroups: entries.asMap().entries.map((mapEntry) {
            final idx = mapEntry.key;
            final entry = mapEntry.value;
            final rods = <BarChartRodStackItem>[];
            var bottom = 0.0;
            for (final action in actionList) {
              final hours = entry.workHoursByAction[action] ?? 0.0;
              if (hours > 0) {
                rods.add(BarChartRodStackItem(
                  bottom,
                  bottom + hours,
                  colorMap[action] ?? Colors.grey,
                ));
                bottom += hours;
              }
            }
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: bottom,
                  rodStackItems: rods,
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
                  '${value.toStringAsFixed(0)}h',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
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

  Widget _buildDonutChart(BuildContext context) {
    final breakdown = projection.workBreakdown;

    return SizedBox(
      key: const Key('visit_work_dashboard_donut_chart'),
      height: 200,
      child: breakdown.isEmpty
          ? Center(
              child: Text(
                '作業データなし',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: breakdown.map((entry) {
                        return PieChartSectionData(
                          value: entry.hours,
                          color: entry.color,
                          title: '${entry.percentage.toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: breakdown.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: entry.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            entry.actionName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
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
                widgetKey: const Key('visit_work_total_work_time_label'),
                label: '総作業時間',
                value: projection.totalWorkTimeLabel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                widgetKey: const Key('visit_work_total_revenue_label'),
                label: '総売上',
                value: projection.totalRevenueLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                widgetKey: const Key('visit_work_hourly_rate_label'),
                label: '時間単価',
                value: projection.hourlyRateLabel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                widgetKey: const Key('visit_work_utilization_rate_label'),
                label: '稼働率',
                value: projection.utilizationRateLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _KpiCard(
          widgetKey: const Key('visit_work_total_distance_label'),
          label: '総走行距離',
          value: projection.totalDistanceLabel,
        ),
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
