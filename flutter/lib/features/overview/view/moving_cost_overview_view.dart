import 'package:flutter/material.dart';
import '../projection/moving_cost_overview_projection.dart';

/// movingCost用サブWidget
/// MovingCostOverviewProjectionをコンストラクタ経由で受け取る（BlocBuilderではない）
class MovingCostOverviewView extends StatelessWidget {
  final MovingCostOverviewProjection projection;

  const MovingCostOverviewView({super.key, required this.projection});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle(title: '距離'),
        _InfoRow(label: '総走行距離', value: projection.totalDistanceLabel),
        const SizedBox(height: 16),
        const _SectionTitle(title: '費用'),
        _InfoRow(label: '給油量', value: projection.totalGasQuantityLabel),
        _InfoRow(label: 'ガソリン代', value: projection.totalGasPriceLabel),
        if (projection.hasFuelData)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const SizedBox(width: 120),
                Expanded(
                  child: Text(
                    key: const Key('movingCostOverview_text_fulltankLabel'),
                    '満タン給油で算出',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        _InfoRow(label: '経費合計', value: projection.totalPaymentLabel),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
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
