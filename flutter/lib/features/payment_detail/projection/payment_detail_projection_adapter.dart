import '../../../domain/transaction/payment/payment_domain.dart';
import 'payment_detail_projection.dart';

class PaymentDetailProjectionAdapter {
  const PaymentDetailProjectionAdapter._();

  static PaymentDetailProjection from(PaymentDomain domain) {
    return PaymentDetailProjection(
      id: domain.id,
      paymentSeq: domain.paymentSeq,
      displayPaymentAmount: '${_formatAmount(domain.paymentAmount)} 円',
      paymentMemberName: domain.paymentMember.memberName,
      splitMemberNames:
          domain.splitMembers.map((m) => m.memberName).toList(),
      paymentMemo: domain.paymentMemo,
    );
  }

  static String _formatAmount(int amount) {
    final str = amount.toString();
    final buf = StringBuffer();
    final len = str.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}
