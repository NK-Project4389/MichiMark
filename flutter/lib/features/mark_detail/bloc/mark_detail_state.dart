import 'package:equatable/equatable.dart';
import '../draft/mark_detail_draft.dart';

/// MarkDetailのDelegate（画面遷移・操作意図の通知）
sealed class MarkDetailDelegate extends Equatable {
  const MarkDetailDelegate();
}

class MarkDetailDismissDelegate extends MarkDetailDelegate {
  const MarkDetailDismissDelegate();

  @override
  List<Object?> get props => [];
}

class MarkDetailOpenMembersSelectionDelegate extends MarkDetailDelegate {
  const MarkDetailOpenMembersSelectionDelegate();

  @override
  List<Object?> get props => [];
}

class MarkDetailOpenActionsSelectionDelegate extends MarkDetailDelegate {
  const MarkDetailOpenActionsSelectionDelegate();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------

sealed class MarkDetailState extends Equatable {
  const MarkDetailState();
}

class MarkDetailLoading extends MarkDetailState {
  const MarkDetailLoading();

  @override
  List<Object?> get props => [];
}

class MarkDetailLoaded extends MarkDetailState {
  final MarkDetailDraft draft;
  final MarkDetailDelegate? delegate;

  const MarkDetailLoaded({
    required this.draft,
    this.delegate,
  });

  MarkDetailLoaded copyWith({
    MarkDetailDraft? draft,
    MarkDetailDelegate? delegate,
  }) {
    return MarkDetailLoaded(
      draft: draft ?? this.draft,
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props => [draft, delegate];
}

class MarkDetailError extends MarkDetailState {
  final String message;
  const MarkDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
