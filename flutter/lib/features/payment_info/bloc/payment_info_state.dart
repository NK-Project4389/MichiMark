import 'package:equatable/equatable.dart';
import '../../../features/event_detail/projection/payment_info_projection.dart';

/// PaymentInfoの遷移意図（BlocListenerがNavigation処理）
sealed class PaymentInfoDelegate extends Equatable {
  const PaymentInfoDelegate();
}

/// 新規作成のPaymentDetailを開く要求
class PaymentInfoOpenNewPaymentDelegate extends PaymentInfoDelegate {
  const PaymentInfoOpenNewPaymentDelegate();

  @override
  List<Object?> get props => [];
}

/// Payment 保存後の再読込完了を EventDetail に通知するデリゲート
class PaymentInfoReloadedDelegate extends PaymentInfoDelegate {
  const PaymentInfoReloadedDelegate();

  @override
  List<Object?> get props => [];
}

/// 既存PaymentのPaymentDetailを開く要求
class PaymentInfoOpenPaymentByIdDelegate extends PaymentInfoDelegate {
  final String paymentId;
  const PaymentInfoOpenPaymentByIdDelegate(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

// ---------------------------------------------------------------------------

sealed class PaymentInfoState extends Equatable {
  const PaymentInfoState();
}

class PaymentInfoLoading extends PaymentInfoState {
  const PaymentInfoLoading();

  @override
  List<Object?> get props => [];
}

class PaymentInfoLoaded extends PaymentInfoState {
  final PaymentInfoProjection projection;
  final String eventId;
  final PaymentInfoDelegate? delegate;

  const PaymentInfoLoaded({
    required this.projection,
    required this.eventId,
    this.delegate,
  });

  PaymentInfoLoaded copyWith({
    PaymentInfoProjection? projection,
    String? eventId,
    PaymentInfoDelegate? delegate,
  }) {
    return PaymentInfoLoaded(
      projection: projection ?? this.projection,
      eventId: eventId ?? this.eventId,
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props => [projection, eventId, delegate];
}

class PaymentInfoError extends PaymentInfoState {
  final String message;
  const PaymentInfoError({required this.message});

  @override
  List<Object?> get props => [message];
}
