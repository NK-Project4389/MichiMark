import 'package:equatable/equatable.dart';
import '../../../features/event_detail/projection/payment_info_projection.dart';

sealed class PaymentInfoEvent extends Equatable {
  const PaymentInfoEvent();
}

/// 画面が表示されたとき（Projectionを親から注入）
class PaymentInfoStarted extends PaymentInfoEvent {
  final String eventId;
  final PaymentInfoProjection projection;

  const PaymentInfoStarted({
    required this.eventId,
    required this.projection,
  });

  @override
  List<Object?> get props => [eventId, projection];
}

/// 一覧の支払アイテムがタップされたとき（既存編集）
class PaymentInfoPaymentTapped extends PaymentInfoEvent {
  final String paymentId;
  const PaymentInfoPaymentTapped(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

/// 追加ボタンが押されたとき（新規作成）
class PaymentInfoPlusButtonTapped extends PaymentInfoEvent {
  const PaymentInfoPlusButtonTapped();

  @override
  List<Object?> get props => [];
}

/// delegate を消費してクリアするとき（画面遷移完了後に dispatch）
class PaymentInfoDelegateConsumed extends PaymentInfoEvent {
  const PaymentInfoDelegateConsumed();

  @override
  List<Object?> get props => [];
}
