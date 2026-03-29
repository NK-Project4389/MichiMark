import 'package:equatable/equatable.dart';

sealed class FuelDetailEvent extends Equatable {
  const FuelDetailEvent();
}

/// 画面が表示されたとき（親FeatureのDraftから初期値を受け取る）
class FuelDetailStarted extends FuelDetailEvent {
  final String pricePerGas;
  final String gasQuantity;
  final String gasPrice;

  const FuelDetailStarted({
    required this.pricePerGas,
    required this.gasQuantity,
    required this.gasPrice,
  });

  @override
  List<Object?> get props => [pricePerGas, gasQuantity, gasPrice];
}

/// ガソリン単価が変更されたとき
class FuelDetailPricePerGasChanged extends FuelDetailEvent {
  final String value;
  const FuelDetailPricePerGasChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// 給油量が変更されたとき
class FuelDetailGasQuantityChanged extends FuelDetailEvent {
  final String value;
  const FuelDetailGasQuantityChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// 合計金額が変更されたとき
class FuelDetailGasPriceChanged extends FuelDetailEvent {
  final String value;
  const FuelDetailGasPriceChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// 計算ボタンが押されたとき
class FuelDetailCalculateTapped extends FuelDetailEvent {
  const FuelDetailCalculateTapped();

  @override
  List<Object?> get props => [];
}

/// クリアボタンが押されたとき
class FuelDetailClearTapped extends FuelDetailEvent {
  const FuelDetailClearTapped();

  @override
  List<Object?> get props => [];
}
