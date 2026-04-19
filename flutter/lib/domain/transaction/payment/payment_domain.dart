import 'package:equatable/equatable.dart';
import '../../master/member/member_domain.dart';
import 'payment_type.dart';

class PaymentDomain extends Equatable {
  final String id;

  /// 表示順
  final int paymentSeq;

  /// 支払金額（単位: 1円）
  final int paymentAmount;

  /// 支払メンバー（必須）
  final MemberDomain paymentMember;

  /// 割り勘メンバー
  final List<MemberDomain> splitMembers;

  /// メモ（任意）
  final String? paymentMemo;

  /// 論理削除フラグ
  final bool isDeleted;

  /// 登録日（初回のみ設定）
  final DateTime createdAt;

  /// 更新日（保存時更新）
  final DateTime updatedAt;

  /// 紐づく MarkLink の ID。null = PaymentInfo タブから直接登録
  final String? markLinkID;

  /// 支払種別。デフォルト: expense（支出）
  final PaymentType paymentType;

  const PaymentDomain({
    required this.id,
    required this.paymentSeq,
    required this.paymentAmount,
    required this.paymentMember,
    this.splitMembers = const [],
    this.paymentMemo,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.markLinkID,
    this.paymentType = PaymentType.expense,
  });

  PaymentDomain copyWith({
    String? id,
    int? paymentSeq,
    int? paymentAmount,
    MemberDomain? paymentMember,
    List<MemberDomain>? splitMembers,
    String? paymentMemo,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? markLinkID,
    bool clearMarkLinkID = false,
    PaymentType? paymentType,
  }) {
    return PaymentDomain(
      id: id ?? this.id,
      paymentSeq: paymentSeq ?? this.paymentSeq,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentMember: paymentMember ?? this.paymentMember,
      splitMembers: splitMembers ?? this.splitMembers,
      paymentMemo: paymentMemo ?? this.paymentMemo,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      markLinkID: clearMarkLinkID ? null : (markLinkID ?? this.markLinkID),
      paymentType: paymentType ?? this.paymentType,
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
        isDeleted,
        createdAt,
        updatedAt,
        markLinkID,
        paymentType,
      ];
}
