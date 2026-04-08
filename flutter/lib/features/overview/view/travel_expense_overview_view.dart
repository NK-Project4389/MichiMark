import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../adapter/travel_expense_overview_adapter.dart';

/// travelExpense用サブWidget
/// TravelExpenseOverviewProjectionをコンストラクタ経由で受け取る（BlocBuilderではない）
class TravelExpenseOverviewView extends StatelessWidget {
  final TravelExpenseOverviewProjection projection;

  static final _currencyFormat = NumberFormat('#,###');

  const TravelExpenseOverviewView({super.key, required this.projection});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _SectionTitle(title: '経費合計'),
        _InfoRow(
          label: '合計',
          value: '${_currencyFormat.format(projection.totalExpense)}円',
        ),
        const SizedBox(height: 16),
        const _SectionTitle(title: 'メンバー別コスト'),
        ...projection.memberCosts.map(
          (cost) => _InfoRow(
            label: cost.memberName,
            value: '${_currencyFormat.format(cost.totalCost)}円',
          ),
        ),
        const SizedBox(height: 16),
        const _SectionTitle(title: '収支バランス'),
        ...projection.memberBalances.map(
          (balance) => _BalanceRow(balance: balance),
        ),
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

class _BalanceRow extends StatelessWidget {
  final MemberBalanceProjection balance;

  static final _currencyFormat = NumberFormat('#,###');

  const _BalanceRow({required this.balance});

  @override
  Widget build(BuildContext context) {
    final isPositive = balance.balance >= 0;
    final color = isPositive
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              balance.memberName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              '${isPositive ? '+' : ''}${_currencyFormat.format(balance.balance)}円',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
