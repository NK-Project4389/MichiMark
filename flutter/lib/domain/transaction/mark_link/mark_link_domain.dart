import 'package:equatable/equatable.dart';
import '../../master/member/member_domain.dart';
import '../../master/action/action_domain.dart';
import 'mark_or_link.dart';

class MarkLinkDomain extends Equatable {
  final String id;

  /// 表示順
  final int markLinkSeq;

  /// マーク（地点）またはリンク（経路）の区分
  final MarkOrLink markLinkType;

  /// 記録日時
  final DateTime markLinkDate;

  /// 名称（任意）
  final String? markLinkName;

  /// 参加メンバー
  final List<MemberDomain> members;

  /// 累積メーター（単位: km）。Mark用
  final int? meterValue;

  /// 区間距離（単位: km）。Link用
  final int? distanceValue;

  /// 行動リスト
  final List<ActionDomain> actions;

  /// メモ（任意）
  final String? memo;

  /// 給油フラグ（false の場合、給油関連フィールドは null を想定）
  final bool isFuel;

  /// ガソリン単価（単位: 1円/L）
  final int? pricePerGas;

  /// 給油量（単位: 0.1L の10倍整数値。例: 30.5L → 305）
  final int? gasQuantity;

  /// 給油金額（単位: 1円）
  final int? gasPrice;

  /// 論理削除フラグ
  final bool isDeleted;

  /// 登録日（初回のみ設定）
  final DateTime createdAt;

  /// 更新日（保存時更新）
  final DateTime updatedAt;

  /// ガソリン支払者。isFuel == true のとき意味を持つ
  final MemberDomain? gasPayer;

  const MarkLinkDomain({
    required this.id,
    required this.markLinkSeq,
    this.markLinkType = MarkOrLink.mark,
    required this.markLinkDate,
    this.markLinkName,
    this.members = const [],
    this.meterValue,
    this.distanceValue,
    this.actions = const [],
    this.memo,
    this.isFuel = false,
    this.pricePerGas,
    this.gasQuantity,
    this.gasPrice,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.gasPayer,
  });

  MarkLinkDomain copyWith({
    String? id,
    int? markLinkSeq,
    MarkOrLink? markLinkType,
    DateTime? markLinkDate,
    String? markLinkName,
    List<MemberDomain>? members,
    int? meterValue,
    int? distanceValue,
    List<ActionDomain>? actions,
    String? memo,
    bool? isFuel,
    int? pricePerGas,
    int? gasQuantity,
    int? gasPrice,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    MemberDomain? gasPayer,
  }) {
    return MarkLinkDomain(
      id: id ?? this.id,
      markLinkSeq: markLinkSeq ?? this.markLinkSeq,
      markLinkType: markLinkType ?? this.markLinkType,
      markLinkDate: markLinkDate ?? this.markLinkDate,
      markLinkName: markLinkName ?? this.markLinkName,
      members: members ?? this.members,
      meterValue: meterValue ?? this.meterValue,
      distanceValue: distanceValue ?? this.distanceValue,
      actions: actions ?? this.actions,
      memo: memo ?? this.memo,
      isFuel: isFuel ?? this.isFuel,
      pricePerGas: pricePerGas ?? this.pricePerGas,
      gasQuantity: gasQuantity ?? this.gasQuantity,
      gasPrice: gasPrice ?? this.gasPrice,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gasPayer: gasPayer ?? this.gasPayer,
    );
  }

  @override
  List<Object?> get props => [
        id,
        markLinkSeq,
        markLinkType,
        markLinkDate,
        markLinkName,
        members,
        meterValue,
        distanceValue,
        actions,
        memo,
        isFuel,
        pricePerGas,
        gasQuantity,
        gasPrice,
        isDeleted,
        createdAt,
        updatedAt,
        gasPayer,
      ];
}
