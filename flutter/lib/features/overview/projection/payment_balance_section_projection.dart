import 'package:equatable/equatable.dart';

/// PaymentDetail 1件分の表示データ
class PaymentBalanceItemProjection extends Equatable {
  /// 対応する PaymentDomain の ID
  final String paymentId;

  /// メモ or「支払 #N」
  final String displayMemo;

  /// 符号付き金額文字列（例: `+15,000`、`-2,000`）
  final String displayAmount;

  /// true なら売上・false なら支出
  final bool isRevenue;

  const PaymentBalanceItemProjection({
    required this.paymentId,
    required this.displayMemo,
    required this.displayAmount,
    required this.isRevenue,
  });

  @override
  List<Object?> get props => [paymentId, displayMemo, displayAmount, isRevenue];
}

/// visitWork OverView の収支セクション全体を表す表示専用データクラス
class PaymentBalanceSectionProjection extends Equatable {
  /// 売上グループの表示アイテム一覧
  final List<PaymentBalanceItemProjection> revenueItems;

  /// 支出グループの表示アイテム一覧
  final List<PaymentBalanceItemProjection> expenseItems;

  /// 売上合計の表示文字列（例: `+18,000`）
  final String revenueTotalLabel;

  /// 支出合計の表示文字列（例: `-3,500`）
  final String expenseTotalLabel;

  /// 収支合計の表示文字列（例: `+14,500`）
  final String balanceTotalLabel;

  /// 収支合計が正か（色分け用）
  final bool balanceTotalIsPositive;

  /// 表示すべき項目が1件以上あるか（空時の非表示制御用）
  final bool hasItems;

  const PaymentBalanceSectionProjection({
    required this.revenueItems,
    required this.expenseItems,
    required this.revenueTotalLabel,
    required this.expenseTotalLabel,
    required this.balanceTotalLabel,
    required this.balanceTotalIsPositive,
    required this.hasItems,
  });

  @override
  List<Object?> get props => [
        revenueItems,
        expenseItems,
        revenueTotalLabel,
        expenseTotalLabel,
        balanceTotalLabel,
        balanceTotalIsPositive,
        hasItems,
      ];
}
