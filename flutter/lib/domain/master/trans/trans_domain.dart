import 'package:equatable/equatable.dart';

class TransDomain extends Equatable {
  final String id;

  /// 交通手段名（入力必須）
  final String transName;

  /// 燃費（単位: 0.1km/L の10倍整数値。例: 15.5km/L → 155）
  final int? kmPerGas;

  /// 車両の累積メーター初期値（単位: km）
  final int? meterValue;

  /// 表示フラグ（true: 表示 / false: 非表示）
  final bool isVisible;

  /// 論理削除フラグ
  final bool isDeleted;

  /// 登録日（初回のみ設定）
  final DateTime createdAt;

  /// 更新日（保存時更新）
  final DateTime updatedAt;

  const TransDomain({
    required this.id,
    required this.transName,
    this.kmPerGas,
    this.meterValue,
    this.isVisible = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  TransDomain copyWith({
    String? id,
    String? transName,
    int? kmPerGas,
    int? meterValue,
    bool? isVisible,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransDomain(
      id: id ?? this.id,
      transName: transName ?? this.transName,
      kmPerGas: kmPerGas ?? this.kmPerGas,
      meterValue: meterValue ?? this.meterValue,
      isVisible: isVisible ?? this.isVisible,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transName,
        kmPerGas,
        meterValue,
        isVisible,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
