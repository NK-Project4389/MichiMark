import 'package:equatable/equatable.dart';
import '../../../../domain/action_time/action_state.dart';

class ActionSettingDetailDraft extends Equatable {
  final String actionName;
  final bool isVisible;

  /// 遷移前の状態。nullは任意状態から遷移可を意味する
  final ActionState? fromState;

  /// 遷移後の状態。nullは状態変化なしのActionを意味する
  final ActionState? toState;

  /// トグル型Action（休憩開始/終了など）かどうか
  final bool isToggle;

  /// 対になるActionのid（例: 休憩開始 ↔ 休憩終了）
  final String? togglePairId;

  const ActionSettingDetailDraft({
    this.actionName = '',
    this.isVisible = true,
    this.fromState,
    this.toState,
    this.isToggle = false,
    this.togglePairId,
  });

  ActionSettingDetailDraft copyWith({
    String? actionName,
    bool? isVisible,
    ActionState? fromState,
    ActionState? toState,
    bool? isToggle,
    String? togglePairId,
    bool clearFromState = false,
    bool clearToState = false,
    bool clearTogglePairId = false,
  }) {
    return ActionSettingDetailDraft(
      actionName: actionName ?? this.actionName,
      isVisible: isVisible ?? this.isVisible,
      fromState: clearFromState ? null : (fromState ?? this.fromState),
      toState: clearToState ? null : (toState ?? this.toState),
      isToggle: isToggle ?? this.isToggle,
      togglePairId: clearTogglePairId ? null : (togglePairId ?? this.togglePairId),
    );
  }

  @override
  List<Object?> get props => [actionName, isVisible, fromState, toState, isToggle, togglePairId];
}
