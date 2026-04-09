import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/aggregation/aggregation_filter.dart';
import '../bloc/aggregation_bloc.dart';
import '../bloc/aggregation_event.dart';
import '../bloc/aggregation_state.dart';
import '../draft/aggregation_draft.dart';
import '../projection/aggregation_projection.dart';

class AggregationPage extends StatelessWidget {
  const AggregationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AggregationBloc, AggregationState>(
      listener: (context, state) {
        final error = state.errorMessage;
        if (error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('集計'),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () => context
                    .read<AggregationBloc>()
                    .add(const AggregationFilterCleared()),
                child: const Text('リセット'),
              ),
            ],
          ),
          body: Column(
            children: [
              _FilterSection(draft: state.draft),
              const Divider(height: 1),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _ResultSection(projection: state.projection),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// フィルタセクション
// ---------------------------------------------------------------------------

class _FilterSection extends StatelessWidget {
  final AggregationDraft draft;

  const _FilterSection({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '期間',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _PeriodChip(
                label: '今月',
                isSelected: draft.filter.dateRange is ThisMonth,
                onTap: () => context
                    .read<AggregationBloc>()
                    .add(const AggregationDateRangeChanged(ThisMonth())),
              ),
              const SizedBox(width: 8),
              _PeriodChip(
                label: '先月',
                isSelected: draft.filter.dateRange is LastMonth,
                onTap: () => context
                    .read<AggregationBloc>()
                    .add(const AggregationDateRangeChanged(LastMonth())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

// ---------------------------------------------------------------------------
// 集計結果セクション
// ---------------------------------------------------------------------------

class _ResultSection extends StatelessWidget {
  final AggregationProjection? projection;

  const _ResultSection({this.projection});

  @override
  Widget build(BuildContext context) {
    final p = projection;
    if (p == null) {
      return const Center(child: Text('集計結果がありません'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          p.filterSummaryLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        _InfoRow(label: 'イベント件数', value: p.eventCountLabel),
        _InfoRow(label: '総走行距離', value: p.totalDistanceLabel),
        _InfoRow(label: 'ガソリン代', value: p.totalGasPriceLabel),
        _InfoRow(label: '経費合計', value: p.totalPaymentLabel),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
