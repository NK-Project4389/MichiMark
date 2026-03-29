import 'package:equatable/equatable.dart';

class FuelDetailDraft extends Equatable {
  /// ガソリン単価入力文字列（例: "150"。未入力時は空文字）
  final String pricePerGas;

  /// 給油量入力文字列（例: "30.0"。未入力時は空文字）
  final String gasQuantity;

  /// 合計金額入力文字列（例: "4500"。未入力時は空文字）
  final String gasPrice;

  const FuelDetailDraft({
    this.pricePerGas = '',
    this.gasQuantity = '',
    this.gasPrice = '',
  });

  FuelDetailDraft copyWith({
    String? pricePerGas,
    String? gasQuantity,
    String? gasPrice,
  }) {
    return FuelDetailDraft(
      pricePerGas: pricePerGas ?? this.pricePerGas,
      gasQuantity: gasQuantity ?? this.gasQuantity,
      gasPrice: gasPrice ?? this.gasPrice,
    );
  }

  @override
  List<Object?> get props => [pricePerGas, gasQuantity, gasPrice];
}
