import 'package:equatable/equatable.dart';

class TransItemProjection extends Equatable {
  final String id;
  final String transName;

  /// 燃費の表示文字列（例: "15.5 km/L"、未設定時は "未設定"）
  final String displayKmPerGas;

  /// 累積メーターの表示文字列（例: "1,000 km"、未設定時は "未設定"）
  final String displayMeterValue;

  final bool isVisible;

  const TransItemProjection({
    required this.id,
    required this.transName,
    required this.displayKmPerGas,
    required this.displayMeterValue,
    required this.isVisible,
  });

  @override
  List<Object?> get props => [
        id,
        transName,
        displayKmPerGas,
        displayMeterValue,
        isVisible,
      ];
}
