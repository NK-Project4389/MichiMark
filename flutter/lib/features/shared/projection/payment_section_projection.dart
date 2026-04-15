import 'package:equatable/equatable.dart';
import 'payment_item_projection.dart';

/// MarkDetail / LinkDetail の支払セクション用表示モデル
class PaymentSectionProjection extends Equatable {
  final List<PaymentItemProjection> items;

  /// 合計金額の表示文字列（例: "3,000 円"）
  final String displayTotalAmount;

  const PaymentSectionProjection({
    required this.items,
    required this.displayTotalAmount,
  });

  static const empty = PaymentSectionProjection(
    items: [],
    displayTotalAmount: '0 円',
  );

  @override
  List<Object?> get props => [items, displayTotalAmount];
}
