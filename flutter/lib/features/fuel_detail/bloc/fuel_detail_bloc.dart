import 'package:flutter_bloc/flutter_bloc.dart';
import '../draft/fuel_detail_draft.dart';
import 'fuel_detail_event.dart';
import 'fuel_detail_state.dart';

class FuelDetailBloc extends Bloc<FuelDetailEvent, FuelDetailState> {
  FuelDetailBloc()
      : super(const FuelDetailState(draft: FuelDetailDraft())) {
    on<FuelDetailStarted>(_onStarted);
    on<FuelDetailPricePerGasChanged>(_onPricePerGasChanged);
    on<FuelDetailGasQuantityChanged>(_onGasQuantityChanged);
    on<FuelDetailGasPriceChanged>(_onGasPriceChanged);
    on<FuelDetailCalculateTapped>(_onCalculateTapped);
    on<FuelDetailClearTapped>(_onClearTapped);
  }

  void _onStarted(
    FuelDetailStarted event,
    Emitter<FuelDetailState> emit,
  ) {
    final draft = FuelDetailDraft(
      pricePerGas: event.pricePerGas,
      gasQuantity: event.gasQuantity,
      gasPrice: event.gasPrice,
    );
    emit(FuelDetailState(draft: draft));
  }

  void _onPricePerGasChanged(
    FuelDetailPricePerGasChanged event,
    Emitter<FuelDetailState> emit,
  ) {
    final draft = state.draft.copyWith(pricePerGas: event.value);
    emit(state.copyWith(
      draft: draft,
      delegate: FuelDetailDraftChanged(draft),
    ));
  }

  void _onGasQuantityChanged(
    FuelDetailGasQuantityChanged event,
    Emitter<FuelDetailState> emit,
  ) {
    final draft = state.draft.copyWith(gasQuantity: event.value);
    emit(state.copyWith(
      draft: draft,
      delegate: FuelDetailDraftChanged(draft),
    ));
  }

  void _onGasPriceChanged(
    FuelDetailGasPriceChanged event,
    Emitter<FuelDetailState> emit,
  ) {
    final draft = state.draft.copyWith(gasPrice: event.value);
    emit(state.copyWith(
      draft: draft,
      delegate: FuelDetailDraftChanged(draft),
    ));
  }

  void _onCalculateTapped(
    FuelDetailCalculateTapped event,
    Emitter<FuelDetailState> emit,
  ) {
    final price = int.tryParse(state.draft.pricePerGas);
    if (price == null || price == 0) return;

    final quantityEmpty = state.draft.gasQuantity.isEmpty;
    final totalEmpty = state.draft.gasPrice.isEmpty;

    // 未入力がちょうど1つのときのみ計算
    if (quantityEmpty == totalEmpty) return;

    FuelDetailDraft draft;

    if (totalEmpty) {
      // 合計が空 → 単価 × 給油量
      final quantity = double.tryParse(state.draft.gasQuantity);
      if (quantity == null) return;
      final total = (price * quantity).round();
      draft = state.draft.copyWith(gasPrice: total.toString());
    } else {
      // 給油量が空 → 合計 ÷ 単価
      final total = int.tryParse(state.draft.gasPrice);
      if (total == null) return;
      final quantity = total / price;
      draft = state.draft.copyWith(
        gasQuantity: quantity.toStringAsFixed(1),
      );
    }

    emit(state.copyWith(
      draft: draft,
      delegate: FuelDetailDraftChanged(draft),
    ));
  }

  void _onClearTapped(
    FuelDetailClearTapped event,
    Emitter<FuelDetailState> emit,
  ) {
    const draft = FuelDetailDraft();
    emit(state.copyWith(
      draft: draft,
      delegate: const FuelDetailDraftChanged(draft),
    ));
  }
}
