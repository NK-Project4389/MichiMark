import 'package:equatable/equatable.dart';
import '../../../../domain/action_time/action_state.dart';

class ActionSettingDetailDraft extends Equatable {
  final String actionName;
  final bool isVisible;

  /// 遷移後の状態。nullは状態変化なしのActionを意味する
  final ActionState? toState;

  /// トグル型Action（休憩開始/終了など）かどうか
  final bool isToggle;

  /// 対になるActionのid（例: 休憩開始 ↔ 休憩終了）
  final String? togglePairId;

  /// 状態遷移フラグ（デフォルト: true）（REQ-005）
  final bool needsTransition;

  const ActionSettingDetailDraft({
    this.actionName = '',
    this.isVisible = true,
    this.toState,
    this.isToggle = false,
    this.togglePairId,
    this.needsTransition = true,
  });

  ActionSettingDetailDraft copyWith({
    String? actionName,
    bool? isVisible,
    ActionState? toState,
    bool? isToggle,
    String? togglePairId,
    bool? needsTransition,
    bool clearToState = false,
    bool clearTogglePairId = false,
  }) {
    return ActionSettingDetailDraft(
      actionName: actionName ?? this.actionName,
      isVisible: isVisible ?? this.isVisible,
      toState: clearToState ? null : (toState ?? this.toState),
      isToggle: isToggle ?? this.isToggle,
      togglePairId: clearTogglePairId ? null : (togglePairId ?? this.togglePairId),
      needsTransition: needsTransition ?? this.needsTransition,
    );
  }

  @override
  List<Object?> get props => [actionName, isVisible, toState, isToggle, togglePairId, needsTransition];
}
