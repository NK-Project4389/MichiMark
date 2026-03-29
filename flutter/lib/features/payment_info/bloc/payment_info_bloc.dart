import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_info_event.dart';
import 'payment_info_state.dart';

class PaymentInfoBloc extends Bloc<PaymentInfoEvent, PaymentInfoState> {
  PaymentInfoBloc() : super(const PaymentInfoLoading()) {
    on<PaymentInfoStarted>(_onStarted);
    on<PaymentInfoPaymentTapped>(_onPaymentTapped);
    on<PaymentInfoPlusButtonTapped>(_onPlusButtonTapped);
  }

  Future<void> _onStarted(
    PaymentInfoStarted event,
    Emitter<PaymentInfoState> emit,
  ) async {
    emit(PaymentInfoLoaded(
      projection: event.projection,
      eventId: event.eventId,
    ));
  }

  Future<void> _onPaymentTapped(
    PaymentInfoPaymentTapped event,
    Emitter<PaymentInfoState> emit,
  ) async {
    if (state is PaymentInfoLoaded) {
      final current = state as PaymentInfoLoaded;
      emit(current.copyWith(
        delegate: PaymentInfoOpenPaymentByIdDelegate(event.paymentId),
      ));
    }
  }

  Future<void> _onPlusButtonTapped(
    PaymentInfoPlusButtonTapped event,
    Emitter<PaymentInfoState> emit,
  ) async {
    if (state is PaymentInfoLoaded) {
      final current = state as PaymentInfoLoaded;
      emit(current.copyWith(
        delegate: const PaymentInfoOpenNewPaymentDelegate(),
      ));
    }
  }
}
