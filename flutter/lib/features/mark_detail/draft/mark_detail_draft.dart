import 'package:equatable/equatable.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../../domain/master/member/member_domain.dart';

class MarkDetailDraft extends Equatable {
  /// マーク名称（任意）
  final String markLinkName;

  /// 記録日
  final DateTime markLinkDate;

  /// 選択中のメンバー
  final List<MemberDomain> selectedMembers;

  /// 累積メーター入力文字列（例: "1234"。未入力時は空文字）
  final String meterValueInput;

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

  const MarkDetailDraft({
    this.markLinkName = '',
    required this.markLinkDate,
    this.selectedMembers = const [],
    this.meterValueInput = '',
    this.selectedActions = const [],
    this.memo = '',
    this.isFuel = false,
    this.pricePerGasInput = '',
    this.gasQuantityInput = '',
    this.gasPriceInput = '',
  });

  MarkDetailDraft copyWith({
    String? markLinkName,
    DateTime? markLinkDate,
    List<MemberDomain>? selectedMembers,
    String? meterValueInput,
    List<ActionDomain>? selectedActions,
    String? memo,
    bool? isFuel,
    String? pricePerGasInput,
    String? gasQuantityInput,
    String? gasPriceInput,
  }) {
    return MarkDetailDraft(
      markLinkName: markLinkName ?? this.markLinkName,
      markLinkDate: markLinkDate ?? this.markLinkDate,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      meterValueInput: meterValueInput ?? this.meterValueInput,
      selectedActions: selectedActions ?? this.selectedActions,
      memo: memo ?? this.memo,
      isFuel: isFuel ?? this.isFuel,
      pricePerGasInput: pricePerGasInput ?? this.pricePerGasInput,
      gasQuantityInput: gasQuantityInput ?? this.gasQuantityInput,
      gasPriceInput: gasPriceInput ?? this.gasPriceInput,
    );
  }

  @override
  List<Object?> get props => [
        markLinkName,
        markLinkDate,
        selectedMembers,
        meterValueInput,
        selectedActions,
        memo,
        isFuel,
        pricePerGasInput,
        gasQuantityInput,
        gasPriceInput,
      ];
}
