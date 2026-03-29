import 'package:equatable/equatable.dart';
import '../../../../features/shared/projection/trans_item_projection.dart';

// ── Delegate ─────────────────────────────────────────────────────────────────

sealed class TransSettingDelegate extends Equatable {
  const TransSettingDelegate();
}

class TransSettingOpenDetailDelegate extends TransSettingDelegate {
  final String transId;
  const TransSettingOpenDetailDelegate(this.transId);

  @override
  List<Object?> get props => [transId];
}

class TransSettingOpenNewDelegate extends TransSettingDelegate {
  const TransSettingOpenNewDelegate();

  @override
  List<Object?> get props => [];
}

// ── State ─────────────────────────────────────────────────────────────────────

sealed class TransSettingState extends Equatable {
  const TransSettingState();
}

class TransSettingLoading extends TransSettingState {
  const TransSettingLoading();

  @override
  List<Object?> get props => [];
}

class TransSettingLoaded extends TransSettingState {
  final List<TransItemProjection> items;
  final TransSettingDelegate? delegate;

  const TransSettingLoaded({
    required this.items,
    this.delegate,
  });

  TransSettingLoaded copyWith({
    List<TransItemProjection>? items,
    TransSettingDelegate? delegate,
  }) {
    return TransSettingLoaded(
      items: items ?? this.items,
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props => [items, delegate];
}

class TransSettingError extends TransSettingState {
  final String message;
  const TransSettingError(this.message);

  @override
  List<Object?> get props => [message];
}
