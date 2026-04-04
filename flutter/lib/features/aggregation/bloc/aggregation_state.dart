import 'package:equatable/equatable.dart';
import '../draft/aggregation_draft.dart';
import '../projection/aggregation_projection.dart';

/// AggregationのDelegate（Phase 1はなし）
sealed class AggregationDelegate extends Equatable {
  const AggregationDelegate();
}

// ---------------------------------------------------------------------------

class AggregationState extends Equatable {
  final AggregationDraft draft;
  final AggregationProjection? projection;
  final bool isLoading;
  final String? errorMessage;
  final AggregationDelegate? delegate;

  const AggregationState({
    required this.draft,
    this.projection,
    this.isLoading = false,
    this.errorMessage,
    this.delegate,
  });

  AggregationState copyWith({
    AggregationDraft? draft,
    AggregationProjection? projection,
    bool? isLoading,
    String? errorMessage,
    AggregationDelegate? delegate,
    bool clearErrorMessage = false,
  }) {
    return AggregationState(
      draft: draft ?? this.draft,
      projection: projection ?? this.projection,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props =>
      [draft, projection, isLoading, errorMessage, delegate];
}
