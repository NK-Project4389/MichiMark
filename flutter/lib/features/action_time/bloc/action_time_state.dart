import 'package:equatable/equatable.dart';
import '../draft/action_time_draft.dart';
import '../projection/action_time_projection.dart';

/// ActionTimeのDelegate
sealed class ActionTimeDelegate extends Equatable {
  const ActionTimeDelegate();
}

/// 記録完了後に前画面へ戻る意図を通知する
class ActionTimeNavigateBackDelegate extends ActionTimeDelegate {
  const ActionTimeNavigateBackDelegate();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------

class ActionTimeState extends Equatable {
  final ActionTimeDraft draft;
  final ActionTimeProjection projection;
  final ActionTimeDelegate? delegate;
  final bool isLoading;
  final String? errorMessage;

  const ActionTimeState({
    required this.draft,
    required this.projection,
    this.delegate,
    this.isLoading = false,
    this.errorMessage,
  });

  ActionTimeState copyWith({
    ActionTimeDraft? draft,
    ActionTimeProjection? projection,
    ActionTimeDelegate? delegate,
    bool? isLoading,
    String? errorMessage,
    bool clearDelegate = false,
    bool clearErrorMessage = false,
  }) {
    return ActionTimeState(
      draft: draft ?? this.draft,
      projection: projection ?? this.projection,
      delegate: clearDelegate ? null : (delegate ?? this.delegate),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [draft, projection, delegate, isLoading, errorMessage];
}
