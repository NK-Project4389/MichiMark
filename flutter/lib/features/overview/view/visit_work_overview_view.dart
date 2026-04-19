import 'package:flutter/material.dart';
import '../../../features/event_detail/projection/visit_work_projection.dart';
import '../../../shared/widgets/visit_work_progress_bar.dart';
import '../projection/payment_balance_section_projection.dart';

/// visitWork 向けサブWidget
/// VisitWorkProjection をコンストラクタ経由で受け取る（BlocBuilderではない）
class VisitWorkOverviewView extends StatelessWidget {
  final VisitWorkProjection projection;

  const VisitWorkOverviewView({super.key, required this.projection});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // プログレスバー（時間軸タイムライン）
        if (projection.timeline.segments.isNotEmpty) ...[
          VisitWorkProgressBar(timeline: projection.timeline),
          const SizedBox(height: 24),
        ],
        // 時間の内訳セクション
        _SectionTitle(title: '時間の内訳'),
        _DurationRow(
          label: '移動',
          value: projection.movingLabel,
          color: Colors.grey.shade400,
        ),
        _DurationRow(
          label: '滞在',
          value: projection.stayingLabel,
          color: Colors.blue.shade300,
        ),
        _DurationRow(
          label: '作業',
          value: projection.workingLabel,
          color: const Color(0xFF1E8A8A),
        ),
        _DurationRow(
          label: '休憩',
          value: projection.breakLabel,
          color: Colors.orange.shade300,
        ),
        const Divider(),
        _InfoRow(label: '在現地', value: '${projection.onSiteLabel}（到着〜出発）'),
        const SizedBox(height: 16),
        // 収支セクション
        if (projection.balanceSection != null &&
            projection.balanceSection!.hasItems)
          _PaymentBalanceSection(
            section: projection.balanceSection!,
            revenuePerHourLabel: projection.revenuePerHourLabel,
          ),
      ],
    );
  }
}

// ── 収支セクション ─────────────────────────────────────────────────────────

class _PaymentBalanceSection extends StatelessWidget {
  final PaymentBalanceSectionProjection section;
  final String? revenuePerHourLabel;

  const _PaymentBalanceSection({
    required this.section,
    required this.revenuePerHourLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('visitWorkOverview_section_balance'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: '収支'),
          // 売上グループ
          if (section.revenueItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '売上',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            ...section.revenueItems.map(
              (item) => _PaymentItemRow(
                key: Key('visitWorkOverview_item_revenue_${item.paymentId}'),
                item: item,
              ),
            ),
            _AmountRow(
              key: const Key('visitWorkOverview_label_revenueTotal'),
              label: '売上合計',
              value: section.revenueTotalLabel,
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 8),
          ],
          // 支出グループ
          if (section.expenseItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '支出',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            ...section.expenseItems.map(
              (item) => _PaymentItemRow(
                key: Key('visitWorkOverview_item_expense_${item.paymentId}'),
                item: item,
              ),
            ),
            _AmountRow(
              key: const Key('visitWorkOverview_label_expenseTotal'),
              label: '支出合計',
              value: section.expenseTotalLabel,
              color: Colors.red.shade700,
            ),
            const SizedBox(height: 8),
          ],
          const Divider(),
          // 収支合計
          _AmountRow(
            key: const Key('visitWorkOverview_label_balanceTotal'),
            label: '収支合計',
            value: section.balanceTotalLabel,
            color: section.balanceTotalIsPositive
                ? Colors.green.shade700
                : Colors.red.shade700,
            isBold: true,
          ),
          // 時給換算
          if (revenuePerHourLabel != null)
            _InfoRow(
              key: const Key('visitWorkOverview_label_revenuePerHour'),
              label: '時給換算',
              value: revenuePerHourLabel!,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PaymentItemRow extends StatelessWidget {
  final PaymentBalanceItemProjection item;

  const _PaymentItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color =
        item.isRevenue ? Colors.green.shade700 : Colors.red.shade700;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.displayMemo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            item.displayAmount,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _AmountRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight:
                        isBold ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ),
        ],
      ),
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

  const _InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
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

class _DurationRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DurationRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
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
