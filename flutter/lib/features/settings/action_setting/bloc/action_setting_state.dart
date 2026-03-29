import 'package:equatable/equatable.dart';
import '../../../../features/shared/projection/action_item_projection.dart';

// ── Delegate ─────────────────────────────────────────────────────────────────

sealed class ActionSettingDelegate extends Equatable {
  const ActionSettingDelegate();
}

class ActionSettingOpenDetailDelegate extends ActionSettingDelegate {
  final String actionId;
  const ActionSettingOpenDetailDelegate(this.actionId);

  @override
  List<Object?> get props => [actionId];
}

class ActionSettingOpenNewDelegate extends ActionSettingDelegate {
  const ActionSettingOpenNewDelegate();

  @override
  List<Object?> get props => [];
}

// ── State ─────────────────────────────────────────────────────────────────────

sealed class ActionSettingState extends Equatable {
  const ActionSettingState();
}

class ActionSettingLoading extends ActionSettingState {
  const ActionSettingLoading();

  @override
  List<Object?> get props => [];
}

class ActionSettingLoaded extends ActionSettingState {
  final List<ActionItemProjection> items;
  final ActionSettingDelegate? delegate;

  const ActionSettingLoaded({
    required this.items,
    this.delegate,
  });

  ActionSettingLoaded copyWith({
    List<ActionItemProjection>? items,
    ActionSettingDelegate? delegate,
  }) {
    return ActionSettingLoaded(
      items: items ?? this.items,
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props => [items, delegate];
}

class ActionSettingError extends ActionSettingState {
  final String message;
  const ActionSettingError(this.message);

  @override
  List<Object?> get props => [message];
}
