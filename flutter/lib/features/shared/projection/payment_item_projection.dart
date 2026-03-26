import 'package:equatable/equatable.dart';
import 'member_item_projection.dart';

class PaymentItemProjection extends Equatable {
  final String id;

  /// 金額の表示文字列（例: "1,500 円"）
  final String displayAmount;

  /// 支払メンバー
  final MemberItemProjection payer;

  /// 割り勘メンバー
  final List<MemberItemProjection> splitMembers;

  final String? memo;

  const PaymentItemProjection({
    required this.id,
    required this.displayAmount,
    required this.payer,
    required this.splitMembers,
    this.memo,
  });

  @override
  List<Object?> get props => [id, displayAmount, payer, splitMembers, memo];
}
