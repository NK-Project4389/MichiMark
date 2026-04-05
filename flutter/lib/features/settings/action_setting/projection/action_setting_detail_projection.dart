import 'package:equatable/equatable.dart';

/// ActionSetting詳細画面の表示用データ
class ActionSettingDetailProjection extends Equatable {
  /// 行動名の表示文字列
  final String actionName;

  /// 表示フラグ
  final bool isVisible;

  /// 遷移後の状態の表示文字列（null = 状態変化なし）
  final String? toStateLabel;

  /// トグル型Actionかどうか
  final bool isToggle;

  /// 対ActionのID（null = 対なし）
  final String? togglePairId;

  /// 状態遷移フラグ（REQ-005）
  final bool needsTransition;

  const ActionSettingDetailProjection({
    required this.actionName,
    required this.isVisible,
    this.toStateLabel,
    required this.isToggle,
    this.togglePairId,
    required this.needsTransition,
  });

  @override
  List<Object?> get props => [
        actionName,
        isVisible,
        toStateLabel,
        isToggle,
        togglePairId,
        needsTransition,
      ];
}
