import 'package:equatable/equatable.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../../domain/master/member/member_domain.dart';

class LinkDetailDraft extends Equatable {
  /// リンク名称（任意）
  final String markLinkName;

  /// 記録日（保持用。LinkDetailでは編集不可）
  final DateTime markLinkDate;

  /// 走行距離入力文字列（例: "123"。未入力時は空文字）
  final String distanceValueInput;

  /// 選択中のメンバー
  final List<MemberDomain> selectedMembers;

  /// 選択中のアクション
  final List<ActionDomain> selectedActions;

  /// メモ（任意）
  final String memo;

  /// 給油フラグ
  final bool isFuel;

  /// ガソリン単価入力文字列（例: "150"。未入力時は空文字）
  final String pricePerGasInput;

  /// 給油量入力文字列（例: "30.0"。未入力時は空文字）
  final String gasQuantityInput;

  /// 合計金額入力文字列（例: "4500"。未入力時は空文字）
  final String gasPriceInput;

  /// 選択中のガソリン支払者（isFuel == true のとき意味を持つ）
  final MemberDomain? selectedGasPayer;

  const LinkDetailDraft({
    this.markLinkName = '',
    required this.markLinkDate,
    this.distanceValueInput = '',
    this.selectedMembers = const [],
    this.selectedActions = const [],
    this.memo = '',
    this.isFuel = false,
    this.pricePerGasInput = '',
    this.gasQuantityInput = '',
    this.gasPriceInput = '',
    this.selectedGasPayer,
  });

  LinkDetailDraft copyWith({
    String? markLinkName,
    DateTime? markLinkDate,
    String? distanceValueInput,
    List<MemberDomain>? selectedMembers,
    List<ActionDomain>? selectedActions,
    String? memo,
    bool? isFuel,
    String? pricePerGasInput,
    String? gasQuantityInput,
    String? gasPriceInput,
    MemberDomain? selectedGasPayer,
  }) {
    return LinkDetailDraft(
      markLinkName: markLinkName ?? this.markLinkName,
      markLinkDate: markLinkDate ?? this.markLinkDate,
      distanceValueInput: distanceValueInput ?? this.distanceValueInput,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      selectedActions: selectedActions ?? this.selectedActions,
      memo: memo ?? this.memo,
      isFuel: isFuel ?? this.isFuel,
      pricePerGasInput: pricePerGasInput ?? this.pricePerGasInput,
      gasQuantityInput: gasQuantityInput ?? this.gasQuantityInput,
      gasPriceInput: gasPriceInput ?? this.gasPriceInput,
      selectedGasPayer: selectedGasPayer ?? this.selectedGasPayer,
    );
  }

  @override
  List<Object?> get props => [
        markLinkName,
        markLinkDate,
        distanceValueInput,
        selectedMembers,
        selectedActions,
        memo,
        isFuel,
        pricePerGasInput,
        gasQuantityInput,
        gasPriceInput,
        selectedGasPayer,
      ];
}
