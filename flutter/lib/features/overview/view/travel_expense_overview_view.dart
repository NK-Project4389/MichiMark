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
        if (projection.perPaymentSettlements.isNotEmpty) ...[
          const SizedBox(height: 16),
          const _SectionTitle(title: '支払いごとの精算'),
          ...projection.perPaymentSettlements.asMap().entries.map(
            (entry) => _PerPaymentSettlementBlock(
              settlement: entry.value,
              blockKey: Key('travelExpenseOverview_block_perPaymentSettlement_${entry.key}'),
            ),
          ),
        ],
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

class _PerPaymentSettlementBlock extends StatelessWidget {
  final PerPaymentSettlementProjection settlement;
  final Key? blockKey;

  const _PerPaymentSettlementBlock({
    required this.settlement,
    this.blockKey,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        key: blockKey,
        decoration: const BoxDecoration(
          color: Color(0xFFEAF5FB),
          border: Border(
            left: BorderSide(
              color: Color(0xFF2B7A9B),
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー行: タイトル + 金額
            Row(
              children: [
                Expanded(
                  child: Text(
                    settlement.displayTitle,
                    style: textTheme.bodyMedium,
                  ),
                ),
                Text(
                  settlement.displayAmount,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF2B7A9B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 精算行一覧
            ...settlement.lines.map(
              (line) => _SettlementLineRow(line: line),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettlementLineRow extends StatelessWidget {
  final SettlementLineProjection line;

  const _SettlementLineRow({required this.line});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            line.payerName,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          Text(' → ', style: textTheme.bodySmall),
          Text(
            line.receiverName,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.green.shade700,
            ),
          ),
          Text(
            ' : ${line.displayAmount}',
            style: textTheme.bodySmall,
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
