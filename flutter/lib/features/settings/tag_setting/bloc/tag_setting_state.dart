import 'package:equatable/equatable.dart';
import '../../../../features/shared/projection/tag_item_projection.dart';

// ── Delegate ─────────────────────────────────────────────────────────────────

sealed class TagSettingDelegate extends Equatable {
  const TagSettingDelegate();
}

class TagSettingOpenDetailDelegate extends TagSettingDelegate {
  final String tagId;
  const TagSettingOpenDetailDelegate(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

class TagSettingOpenNewDelegate extends TagSettingDelegate {
  const TagSettingOpenNewDelegate();

  @override
  List<Object?> get props => [];
}

// ── State ─────────────────────────────────────────────────────────────────────

sealed class TagSettingState extends Equatable {
  const TagSettingState();
}

class TagSettingLoading extends TagSettingState {
  const TagSettingLoading();

  @override
  List<Object?> get props => [];
}

class TagSettingLoaded extends TagSettingState {
  final List<TagItemProjection> items;
  final TagSettingDelegate? delegate;

  const TagSettingLoaded({
    required this.items,
    this.delegate,
  });

  TagSettingLoaded copyWith({
    List<TagItemProjection>? items,
    TagSettingDelegate? delegate,
  }) {
    return TagSettingLoaded(
      items: items ?? this.items,
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props => [items, delegate];
}

class TagSettingError extends TagSettingState {
  final String message;
  const TagSettingError(this.message);

  @override
  List<Object?> get props => [message];
}
