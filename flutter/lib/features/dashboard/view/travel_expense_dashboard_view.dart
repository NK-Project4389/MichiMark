import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../projection/travel_expense_dashboard_projection.dart';

class TravelExpenseDashboardView extends StatelessWidget {
  final TravelExpenseDashboardProjection projection;

  const TravelExpenseDashboardView({super.key, required this.projection});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendar(context),
          const SizedBox(height: 24),
          _buildKpiCards(context),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final entryMap = <DateTime, List<TravelEventCalendarEntry>>{};
    for (final entry in projection.calendarEntries) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      entryMap.putIfAbsent(day, () => []).add(entry);
    }

    return TableCalendar<TravelEventCalendarEntry>(
      key: const Key('travel_expense_calendar'),
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: projection.displayMonth,
      currentDay: DateTime.now(),
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      eventLoader: (day) {
        final key = DateTime(day.year, day.month, day.day);
        return entryMap[key] ?? [];
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: events.take(3).map((e) {
              return Container(
                key: Key('travel_calendar_badge_${e.eventId}'),
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: e.topicColor,
                ),
              );
            }).toList(),
          );
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        final key = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
        final entries = entryMap[key];
        if (entries != null && entries.isNotEmpty) {
          context.read<DashboardBloc>().add(
                DashboardTravelEventTapped(entries.first.eventId),
              );
        }
      },
      onPageChanged: (focusedDay) {
        context.read<DashboardBloc>().add(DashboardMonthChanged(focusedDay));
      },
    );
  }

  Widget _buildKpiCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            widgetKey: const Key('travel_expense_trip_count_label'),
            label: '旅行回数',
            value: projection.tripCountLabel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiCard(
            widgetKey: const Key('travel_expense_spot_count_label'),
            label: '訪問スポット',
            value: projection.spotCountLabel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiCard(
            widgetKey: const Key('travel_expense_total_expense_label'),
            label: '総支出（今月）',
            value: projection.totalExpenseLabel,
          ),
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
        padding: const EdgeInsets.all(12),
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
