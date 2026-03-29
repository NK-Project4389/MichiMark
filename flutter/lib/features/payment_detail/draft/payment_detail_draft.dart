import 'package:equatable/equatable.dart';
import '../../../domain/master/member/member_domain.dart';

class PaymentDetailDraft extends Equatable {
  /// 支払ID（UUID文字列）
  final String id;

  /// 表示順
  final int paymentSeq;

  /// 支払金額入力文字列（例: "1500"。未入力時は空文字）
  final String paymentAmount;

  /// 選択中の支払メンバー（未選択時はnull）
  final MemberDomain? paymentMember;

  /// 選択中の割り勘メンバー
  final List<MemberDomain> splitMembers;

  /// メモ（任意）
  final String paymentMemo;

  const PaymentDetailDraft({
    required this.id,
    required this.paymentSeq,
    this.paymentAmount = '',
    this.paymentMember,
    this.splitMembers = const [],
    this.paymentMemo = '',
  });

  PaymentDetailDraft copyWith({
    String? id,
    int? paymentSeq,
    String? paymentAmount,
    MemberDomain? paymentMember,
    List<MemberDomain>? splitMembers,
    String? paymentMemo,
  }) {
    return PaymentDetailDraft(
      id: id ?? this.id,
      paymentSeq: paymentSeq ?? this.paymentSeq,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentMember: paymentMember ?? this.paymentMember,
      splitMembers: splitMembers ?? this.splitMembers,
      paymentMemo: paymentMemo ?? this.paymentMemo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        paymentSeq,
        paymentAmount,
        paymentMember,
        splitMembers,
        paymentMemo,
      ];
}
