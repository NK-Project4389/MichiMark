import 'package:intl/intl.dart';
import '../domain/transaction/payment/payment_domain.dart';
import '../features/shared/projection/member_item_projection.dart';
import '../features/shared/projection/payment_item_projection.dart';
import '../features/shared/projection/payment_section_projection.dart';
import '../domain/master/member/member_domain.dart';

/// List<PaymentDomain> → PaymentSectionProjection の変換
///
/// markLinkID でフィルタしてセクション用 Projection を生成する。
class PaymentSectionProjectionAdapter {
  PaymentSectionProjectionAdapter._();

  static final _numberFormat = NumberFormat('#,###');

  static PaymentSectionProjection toProjection({
    required List<PaymentDomain> allPayments,
    required String markLinkId,
  }) {
    final filtered = allPayments
        .where((p) => !p.isDeleted && p.markLinkID == markLinkId)
        .toList()
      ..sort((a, b) => a.paymentSeq.compareTo(b.paymentSeq));

    final total = filtered.fold(0, (sum, p) => sum + p.paymentAmount);

    return PaymentSectionProjection(
      items: filtered.map(_toPaymentItem).toList(),
      displayTotalAmount: '${_numberFormat.format(total)}円',
    );
  }

  static PaymentItemProjection _toPaymentItem(PaymentDomain d) =>
      PaymentItemProjection(
        id: d.id,
        displayAmount: '${_numberFormat.format(d.paymentAmount)}円',
        payer: _toMemberItem(d.paymentMember),
        splitMembers: d.splitMembers.map(_toMemberItem).toList(),
        memo: d.paymentMemo,
      );

  static MemberItemProjection _toMemberItem(MemberDomain d) =>
      MemberItemProjection(
        id: d.id,
        memberName: d.memberName,
        mailAddress: d.mailAddress,
        isVisible: d.isVisible,
      );
}
