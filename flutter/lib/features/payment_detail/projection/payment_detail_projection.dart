import 'package:equatable/equatable.dart';

class PaymentDetailProjection extends Equatable {
  final String id;
  final int paymentSeq;

  /// 金額の表示文字列（例: "1,500 円"）
  final String displayPaymentAmount;

  /// 支払メンバーの表示名（未選択時: '未選択'）
  final String paymentMemberName;

  /// 割り勘メンバーの表示名一覧
  final List<String> splitMemberNames;

  final String? paymentMemo;

  const PaymentDetailProjection({
    required this.id,
    required this.paymentSeq,
    required this.displayPaymentAmount,
    required this.paymentMemberName,
    required this.splitMemberNames,
    this.paymentMemo,
  });

  @override
  List<Object?> get props => [
        id,
        paymentSeq,
        displayPaymentAmount,
        paymentMemberName,
        splitMemberNames,
        paymentMemo,
      ];
}
