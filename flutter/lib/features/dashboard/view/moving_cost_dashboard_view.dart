import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../shared/theme/graph_tooltip_constants.dart';
import '../projection/moving_cost_dashboard_projection.dart';

class MovingCostDashboardView extends StatefulWidget {
  final MovingCostDashboardProjection projection;

  const MovingCostDashboardView({super.key, required this.projection});

  @override
  State<MovingCostDashboardView> createState() =>
      _MovingCostDashboardViewState();
}

class _MovingCostDashboardViewState extends State<MovingCostDashboardView> {
  bool _isLongPressing = false;
  int? _longPressedBarIndex;
  int? _tappedBarIndex;
  // FlTapDownEvent で取得したバーインデックスを FlTapUpEvent まで保持する。
  // fl_chart は FlTapUpEvent 時点で response?.spot が null になるため、
  // FlTapDownEvent の値を引き継いで使う。
  int? _pendingTapIndex;

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
    final entries = widget.projection.dailyEntries;
    final maxDistance =
        entries.fold(0.0, (m, e) => e.distanceKm > m ? e.distanceKm : m);
    final maxCost = entries.fold(
        0, (m, e) => e.cumulativeCostYen > m ? e.cumulativeCostYen : m);

    final showTapTooltip = !_isLongPressing && _tappedBarIndex != null;
    final showLongPressTooltip =
        _isLongPressing && _longPressedBarIndex != null;

    return Stack(
      children: [
        SizedBox(
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
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.7),
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
              barTouchData: BarTouchData(
                touchCallback: (event, response) {
                  final touchedIndex =
                      response?.spot?.touchedBarGroupIndex;

                  if (event is FlTapDownEvent) {
                    // fl_chart は FlTapUpEvent 時点で spot が null になることがある。
                    // DownEvent で取得したインデックスを UpEvent まで保持する。
                    if (touchedIndex != null) {
                      _pendingTapIndex = touchedIndex;
                    }
                  } else if (event is FlPanDownEvent) {
                    // integration test 環境で tester.tapAt() が PanGesture として
                    // 解釈される場合の対処。FlPanDownEvent でも保持する。
                    if (touchedIndex != null) {
                      _pendingTapIndex = touchedIndex;
                    }
                  } else if (event is FlPanUpdateEvent) {
                    // 実際のドラッグ操作では _pendingTapIndex をクリアして
                    // タップとドラッグを区別する。
                    _pendingTapIndex = null;
                  } else if (event is FlLongPressStart) {
                    setState(() {
                      _isLongPressing = true;
                      // touchedIndex が null の場合は直前のタップ位置を引き継ぐ
                      _longPressedBarIndex =
                          touchedIndex ?? _pendingTapIndex ?? _tappedBarIndex ?? _longPressedBarIndex;
                      _tappedBarIndex = null;
                      _pendingTapIndex = null;
                    });
                  } else if (event is FlLongPressMoveUpdate) {
                    final newIndex = touchedIndex ?? _longPressedBarIndex;
                    if (newIndex != null && newIndex != _longPressedBarIndex) {
                      setState(() {
                        _longPressedBarIndex = newIndex;
                      });
                    } else if (_longPressedBarIndex == null &&
                        newIndex != null) {
                      setState(() {
                        _longPressedBarIndex = newIndex;
                      });
                    }
                  } else if (event is FlLongPressEnd) {
                    setState(() {
                      _isLongPressing = false;
                      _longPressedBarIndex = null;
                      _pendingTapIndex = null;
                    });
                  } else if (event is FlTapUpEvent ||
                      event is FlPanEndEvent) {
                    // touchedIndex が null のときは FlTapDownEvent で保存した値を使う。
                    final resolvedIndex =
                        touchedIndex ?? _pendingTapIndex;
                    _pendingTapIndex = null;
                    if (resolvedIndex != null && !_isLongPressing) {
                      setState(() {
                        _tappedBarIndex = resolvedIndex;
                      });
                    }
                  }
                },
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                      GraphTooltipConstants.graphTooltipBackgroundColor,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (groupIndex < 0 || groupIndex >= entries.length) {
                      return null;
                    }
                    final entry = entries[groupIndex];
                    final isLongPress = _isLongPressing &&
                        _longPressedBarIndex == groupIndex;

                    if (isLongPress) {
                      final distanceText =
                          '${entry.distanceKm.toStringAsFixed(1)} km';
                      final costText = _formatCost(entry.costYen);
                      return BarTooltipItem(
                        '${entry.dateLabel}\n$distanceText\n$costText',
                        const TextStyle(
                          color: GraphTooltipConstants.graphTooltipTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    } else {
                      final costText = _formatCost(entry.costYen);
                      return BarTooltipItem(
                        '${entry.dateLabel}\n$costText',
                        const TextStyle(
                          color: GraphTooltipConstants.graphTooltipTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        // テスト用キー付き不可視 Widget（タップ時ポップアップ表示確認）
        // fl_chart のツールチップは Widget ツリーに直接キーを付けられないため、
        // ローカルステートと連動した不可視 Semantics Widget をチャートに重ねる。
        if (showTapTooltip)
          Positioned(
            key: const Key('movingCost_tooltip_tap'),
            right: 0,
            top: 0,
            child: _TooltipTestMarker(
              semanticsLabel: () {
                final idx = _tappedBarIndex!;
                if (idx >= 0 && idx < entries.length) {
                  final entry = entries[idx];
                  return '${entry.dateLabel} ${_formatCost(entry.costYen)}';
                }
                return '';
              }(),
            ),
          ),
        // テスト用キー付き不可視 Widget（長押し時ポップアップ表示確認）
        if (showLongPressTooltip)
          Positioned(
            key: const Key('movingCost_tooltip_longpress'),
            right: 0,
            top: 0,
            child: _TooltipTestMarker(
              semanticsLabel: () {
                final idx = _longPressedBarIndex!;
                if (idx >= 0 && idx < entries.length) {
                  final entry = entries[idx];
                  final distanceText =
                      '${entry.distanceKm.toStringAsFixed(1)} km';
                  final costText = _formatCost(entry.costYen);
                  return '${entry.dateLabel} $distanceText $costText';
                }
                return '';
              }(),
            ),
          ),
      ],
    );
  }

  String _formatCost(int? costYen) {
    if (!widget.projection.hasFuelData || costYen == null) {
      return '---';
    }
    return '¥${costYen.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        )}';
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
                value: widget.projection.totalDistanceLabel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                widgetKey: const Key('moving_cost_total_cost_label'),
                label: '総コスト',
                value: widget.projection.totalCostLabel,
              ),
            ),
          ],
        ),
        if (widget.projection.hasFuelData) ...[
          const SizedBox(height: 12),
          _KpiCard(
            widgetKey: const Key('moving_cost_avg_fuel_label'),
            label: '平均燃費',
            value: widget.projection.avgFuelEfficiencyLabel,
          ),
        ],
      ],
    );
  }
}

/// テスト検証用マーカーWidget。
///
/// fl_chart のツールチップは Widget ツリーに直接キーを付けられないため、
/// ローカルステートと連動した不可視 Widget をチャートに重ねることで
/// Integration Test からのキー参照を可能にする。
class _TooltipTestMarker extends StatelessWidget {
  final String semanticsLabel;

  const _TooltipTestMarker({required this.semanticsLabel});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: const SizedBox(width: 1, height: 1),
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
