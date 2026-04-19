import 'package:intl/intl.dart';
import '../domain/transaction/payment/payment_domain.dart';
import '../domain/transaction/payment/payment_type.dart';
import '../features/overview/projection/payment_balance_section_projection.dart';

/// `List<PaymentDomain>` → `PaymentBalanceSectionProjection` への変換を担当する Adapter
class PaymentBalanceSectionAdapter {
  PaymentBalanceSectionAdapter._();

  static final _currencyFormat = NumberFormat('#,###');

  static PaymentBalanceSectionProjection toProjection(
    List<PaymentDomain> payments,
  ) {
    // 論理削除済みを除外
    final active = payments.where((p) => !p.isDeleted).toList();

    final revenuePayments =
        active.where((p) => p.paymentType == PaymentType.revenue).toList();
    final expensePayments =
        active.where((p) => p.paymentType == PaymentType.expense).toList();

    final revenueItems = _toItems(revenuePayments, isRevenue: true);
    final expenseItems = _toItems(expensePayments, isRevenue: false);

    final revenueTotal =
        revenuePayments.fold<int>(0, (sum, p) => sum + p.paymentAmount);
    final expenseTotal =
        expensePayments.fold<int>(0, (sum, p) => sum + p.paymentAmount);
    final balanceTotal = revenueTotal - expenseTotal;

    final hasItems = revenueItems.isNotEmpty || expenseItems.isNotEmpty;

    return PaymentBalanceSectionProjection(
      revenueItems: revenueItems,
      expenseItems: expenseItems,
      revenueTotalLabel: '+${_currencyFormat.format(revenueTotal)}',
      expenseTotalLabel: '-${_currencyFormat.format(expenseTotal)}',
      balanceTotalLabel: _formatBalance(balanceTotal),
      balanceTotalIsPositive: balanceTotal >= 0,
      hasItems: hasItems,
    );
  }

  static List<PaymentBalanceItemProjection> _toItems(
    List<PaymentDomain> payments, {
    required bool isRevenue,
  }) {
    final result = <PaymentBalanceItemProjection>[];
    for (var i = 0; i < payments.length; i++) {
      final p = payments[i];
      final memo = (p.paymentMemo != null && p.paymentMemo!.isNotEmpty)
          ? p.paymentMemo!
          : '支払 #${i + 1}';
      final amount = isRevenue
          ? '+${_currencyFormat.format(p.paymentAmount)}'
          : '-${_currencyFormat.format(p.paymentAmount)}';
      result.add(PaymentBalanceItemProjection(
        paymentId: p.id,
        displayMemo: memo,
        displayAmount: amount,
        isRevenue: isRevenue,
      ));
    }
    return result;
  }

  static String _formatBalance(int amount) {
    if (amount >= 0) {
      return '+${_currencyFormat.format(amount)}';
    } else {
      return '-${_currencyFormat.format(amount.abs())}';
    }
  }
}
