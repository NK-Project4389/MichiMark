import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../adapter/event_detail_adapter.dart';
import '../../../repository/event_repository.dart';
import 'payment_info_event.dart';
import 'payment_info_state.dart';

class PaymentInfoBloc extends Bloc<PaymentInfoEvent, PaymentInfoState> {
  PaymentInfoBloc({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const PaymentInfoLoading()) {
    on<PaymentInfoStarted>(_onStarted);
    on<PaymentInfoPaymentTapped>(_onPaymentTapped);
    on<PaymentInfoPlusButtonTapped>(_onPlusButtonTapped);
    on<PaymentInfoDelegateConsumed>(_onDelegateConsumed);
    on<PaymentInfoReloadRequested>(_onReloadRequested);
    on<PaymentInfoPaymentDeleteRequested>(_onPaymentDeleteRequested);
  }

  final EventRepository _eventRepository;
  String _eventId = '';

  Future<void> _onStarted(
    PaymentInfoStarted event,
    Emitter<PaymentInfoState> emit,
  ) async {
    _eventId = event.eventId;
    emit(PaymentInfoLoaded(
      projection: event.projection,
      eventId: event.eventId,
    ));
  }

  Future<void> _onReloadRequested(
    PaymentInfoReloadRequested event,
    Emitter<PaymentInfoState> emit,
  ) async {
    if (_eventId.isEmpty) return;
    try {
      final domain = await _eventRepository.fetch(_eventId);
      final projection = EventDetailAdapter.toProjection(domain).paymentInfo;
      emit(PaymentInfoLoaded(
        projection: projection,
        eventId: _eventId,
        delegate: const PaymentInfoReloadedDelegate(),
      ));
    } on Exception {
      // リロード失敗は無視（現在の状態を維持）
    }
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

  Future<void> _onDelegateConsumed(
    PaymentInfoDelegateConsumed event,
    Emitter<PaymentInfoState> emit,
  ) async {
    if (state is PaymentInfoLoaded) {
      final current = state as PaymentInfoLoaded;
      emit(current.copyWith());
    }
  }

  Future<void> _onPaymentDeleteRequested(
    PaymentInfoPaymentDeleteRequested event,
    Emitter<PaymentInfoState> emit,
  ) async {
    if (state case PaymentInfoLoaded current) {
      try {
        await _eventRepository.deletePayment(event.paymentId);
        final domain = await _eventRepository.fetch(_eventId);
        final projection = EventDetailAdapter.toProjection(domain).paymentInfo;
        emit(current.copyWith(projection: projection));
      } on Exception {
        // サイレント失敗（既存の projection を維持）
      }
    }
  }
}
