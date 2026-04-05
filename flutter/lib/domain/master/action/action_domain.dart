import 'package:equatable/equatable.dart';
import '../../action_time/action_state.dart';

class ActionDomain extends Equatable {
  final String id;

  /// アクション名（入力必須）
  final String actionName;

  /// 表示フラグ（true: 表示 / false: 非表示）
  final bool isVisible;

  /// 論理削除フラグ
  final bool isDeleted;

  /// 登録日（初回のみ設定）
  final DateTime createdAt;

  /// 更新日（保存時更新）
  final DateTime updatedAt;

  /// 遷移後の状態。nullは状態変化なしのActionを意味する
  final ActionState? toState;

  /// トグル型Action（休憩開始/終了など）かどうか
  final bool isToggle;

  /// 対になるActionのid（例: 休憩開始 ↔ 休憩終了）
  final String? togglePairId;

  /// 状態遷移フラグ。trueのときtoStateへの状態遷移を発生させる。
  /// falseのときログ記録のみで状態遷移しない（REQ-005）
  final bool needsTransition;

  const ActionDomain({
    required this.id,
    required this.actionName,
    this.isVisible = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.toState,
    this.isToggle = false,
    this.togglePairId,
    this.needsTransition = true,
  });

  ActionDomain copyWith({
    String? id,
    String? actionName,
    bool? isVisible,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    ActionState? toState,
    bool? isToggle,
    String? togglePairId,
    bool? needsTransition,
    bool clearToState = false,
    bool clearTogglePairId = false,
  }) {
    return ActionDomain(
      id: id ?? this.id,
      actionName: actionName ?? this.actionName,
      isVisible: isVisible ?? this.isVisible,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      toState: clearToState ? null : (toState ?? this.toState),
      isToggle: isToggle ?? this.isToggle,
      togglePairId: clearTogglePairId ? null : (togglePairId ?? this.togglePairId),
      needsTransition: needsTransition ?? this.needsTransition,
    );
  }

  @override
  List<Object?> get props => [
        id,
        actionName,
        isVisible,
        isDeleted,
        createdAt,
        updatedAt,
        toState,
        isToggle,
        togglePairId,
        needsTransition,
      ];
}
