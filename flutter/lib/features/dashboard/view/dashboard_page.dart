import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'moving_cost_dashboard_view.dart';
import 'travel_expense_dashboard_view.dart';
import 'visit_work_dashboard_view.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        final delegate = state.delegate;
        if (delegate == null) return;

        switch (delegate) {
          case DashboardNavigateToEventDetail(:final eventId):
            context.push('/event/$eventId');
            context.read<DashboardBloc>().add(const DashboardDelegateConsumed());
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('ダッシュボード'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              if (state.availableTopics.isNotEmpty)
                _TopicChipRow(
                  topics: state.availableTopics,
                  selectedTopic: state.selectedTopic,
                ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DashboardState state) {
    final topic = state.selectedTopic;
    if (topic == null) {
      return const Center(
        key: Key('dashboard_empty_placeholder'),
        child: Text('データがありません'),
      );
    }

    switch (topic) {
      case TopicType.movingCost:
      case TopicType.movingCostEstimated:
        final projection = state.movingCostProjection;
        if (projection == null) {
          return const Center(
            key: Key('dashboard_empty_placeholder'),
            child: Text('データがありません'),
          );
        }
        return MovingCostDashboardView(projection: projection);
      case TopicType.travelExpense:
        final projection = state.travelExpenseProjection;
        if (projection == null) {
          return const Center(
            key: Key('dashboard_empty_placeholder'),
            child: Text('データがありません'),
          );
        }
        return TravelExpenseDashboardView(projection: projection);
      case TopicType.visitWork:
        final projection = state.visitWorkProjection;
        if (projection == null) {
          return const Center(
            key: Key('dashboard_empty_placeholder'),
            child: Text('データがありません'),
          );
        }
        return VisitWorkDashboardView(projection: projection);
    }
  }
}

class _TopicChipRow extends StatelessWidget {
  final List<TopicType> topics;
  final TopicType? selectedTopic;

  const _TopicChipRow({required this.topics, required this.selectedTopic});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: topics.length,
        separatorBuilder: (context2, idx) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final topic = topics[index];
          final config = TopicConfig.fromTopicType(topic);
          final isSelected = topic == selectedTopic;
          return FilterChip(
            key: Key('topic_chip_${topic.name}'),
            label: Text(config.displayName),
            selected: isSelected,
            selectedColor: config.themeColor.primaryColor.withValues(alpha: 0.2),
            checkmarkColor: config.themeColor.primaryColor,
            labelStyle: TextStyle(
              color: isSelected
                  ? config.themeColor.primaryColor
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (_) {
              context.read<DashboardBloc>().add(DashboardTopicSelected(topic));
            },
          );
        },
      ),
    );
  }
}
