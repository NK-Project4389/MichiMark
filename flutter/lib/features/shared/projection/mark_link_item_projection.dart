import 'package:equatable/equatable.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import 'member_item_projection.dart';
import 'action_item_projection.dart';

class MarkLinkItemProjection extends Equatable {
  final String id;

  /// 表示順
  final int markLinkSeq;

  /// マーク / リンク 区分
  final MarkOrLink markLinkType;

  /// 日付の表示文字列（例: "2026/03/26"）
  final String displayDate;

  /// 名称
  final String markLinkName;

  /// 参加メンバー
  final List<MemberItemProjection> members;

  /// 累積メーターの表示文字列（例: "1,234 km"）。Mark用
  final String? displayMeterValue;

  /// 区間距離の表示文字列（例: "10.6 km"）。Link用
  final String? displayDistanceValue;

  /// 行動リスト
  final List<ActionItemProjection> actions;

  final bool isFuel;

  /// ガソリン単価（単位: 1円/L）
  final int? pricePerGas;

  /// 給油量（単位: 0.1L の実数値。例: 305 → 30.5）
  final double? gasQuantity;

  /// 給油金額（単位: 1円）
  final int? gasPrice;

  final String? memo;

  const MarkLinkItemProjection({
    required this.id,
    required this.markLinkSeq,
    required this.markLinkType,
    required this.displayDate,
    required this.markLinkName,
    required this.members,
    this.displayMeterValue,
    this.displayDistanceValue,
    required this.actions,
    required this.isFuel,
    this.pricePerGas,
    this.gasQuantity,
    this.gasPrice,
    this.memo,
  });

  @override
  List<Object?> get props => [
        id,
        markLinkSeq,
        markLinkType,
        displayDate,
        markLinkName,
        members,
        displayMeterValue,
        displayDistanceValue,
        actions,
        isFuel,
        pricePerGas,
        gasQuantity,
        gasPrice,
        memo,
      ];
}
