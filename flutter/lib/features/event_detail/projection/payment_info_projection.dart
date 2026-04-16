import 'package:equatable/equatable.dart';
import '../../shared/projection/payment_item_projection.dart';

/// 日付グループ
class PaymentDateGroupProjection extends Equatable {
  /// "2026/04/15" 形式
  final String displayDate;
  final List<PaymentNameGroupProjection> nameGroups;

  const PaymentDateGroupProjection({
    required this.displayDate,
    required this.nameGroups,
  });

  @override
  List<Object?> get props => [displayDate, nameGroups];
}

/// 名称（MarkDetail/LinkDetail）グループ
class PaymentNameGroupProjection extends Equatable {
  final String markLinkId;

  /// markLinkName（null の場合は "名称なし"）
  final String displayName;
  final List<PaymentItemProjection> items;

  /// グループ内合計金額
  final String displayGroupTotal;

  const PaymentNameGroupProjection({
    required this.markLinkId,
    required this.displayName,
    required this.items,
    required this.displayGroupTotal,
  });

  @override
  List<Object?> get props => [markLinkId, displayName, items, displayGroupTotal];
}

class PaymentInfoProjection extends Equatable {
  /// markLinkID != null の支払いを日付→名称でグループ化したもの
  final List<PaymentDateGroupProjection> dateGroups;

  /// markLinkID == null の支払い（PaymentInfo タブから直接登録）
  final List<PaymentItemProjection> directItems;

  /// 合計金額の表示文字列（例: "3,500 円"）
  final String displayTotalAmount;

  /// メンバー別精算セクションを表示するか（visitWork の場合は false）
  final bool showMemberSection;

  const PaymentInfoProjection({
    required this.dateGroups,
    required this.directItems,
    required this.displayTotalAmount,
    this.showMemberSection = true,
  });

  static const empty = PaymentInfoProjection(
    dateGroups: [],
    directItems: [],
    displayTotalAmount: '0 円',
    showMemberSection: true,
  );

  @override
  List<Object?> get props => [dateGroups, directItems, displayTotalAmount, showMemberSection];
}
