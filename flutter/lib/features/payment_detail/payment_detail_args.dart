/// go_router の extra 経由で PaymentDetailPage に渡す引数
class PaymentDetailArgs {
  final String eventId;

  /// 既存編集時は paymentId を指定。null = 新規作成
  final String? paymentId;

  /// MarkDetail/LinkDetail から開く場合に指定。null = PaymentInfo からの直接登録
  final String? markLinkID;

  const PaymentDetailArgs({
    required this.eventId,
    this.paymentId,
    this.markLinkID,
  });
}
