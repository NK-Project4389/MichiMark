import 'package:equatable/equatable.dart';

class TransSettingDetailDraft extends Equatable {
  /// 交通手段名
  final String transName;

  /// 燃費の入力文字列（例: "15.5"、未入力時は空文字）
  final String displayKmPerGas;

  /// メーター値の入力文字列（カンマ区切り。例: "10,000"、未入力時は空文字）
  final String displayMeterValue;

  final bool isVisible;

  const TransSettingDetailDraft({
    this.transName = '',
    this.displayKmPerGas = '',
    this.displayMeterValue = '',
    this.isVisible = true,
  });

  TransSettingDetailDraft copyWith({
    String? transName,
    String? displayKmPerGas,
    String? displayMeterValue,
    bool? isVisible,
  }) {
    return TransSettingDetailDraft(
      transName: transName ?? this.transName,
      displayKmPerGas: displayKmPerGas ?? this.displayKmPerGas,
      displayMeterValue: displayMeterValue ?? this.displayMeterValue,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  /// displayKmPerGas → kmPerGas (int?: 0.1km/L単位の10倍整数)
  int? get kmPerGas {
    final raw = displayKmPerGas.trim();
    if (raw.isEmpty) return null;
    final value = double.tryParse(raw);
    if (value == null) return null;
    return (value * 10).round();
  }

  /// displayMeterValue → meterValue (int?)
  int? get meterValue {
    final raw = displayMeterValue.replaceAll(',', '').trim();
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  @override
  List<Object?> get props => [
        transName,
        displayKmPerGas,
        displayMeterValue,
        isVisible,
      ];
}
