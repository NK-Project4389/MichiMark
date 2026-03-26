import 'package:equatable/equatable.dart';
import '../../shared/projection/payment_item_projection.dart';

class PaymentInfoProjection extends Equatable {
  final List<PaymentItemProjection> items;

  /// 合計金額の表示文字列（例: "3,500 円"）
  final String displayTotalAmount;

  const PaymentInfoProjection({
    required this.items,
    required this.displayTotalAmount,
  });

  static const empty = PaymentInfoProjection(
    items: [],
    displayTotalAmount: '0 円',
  );

  @override
  List<Object?> get props => [items, displayTotalAmount];
}
