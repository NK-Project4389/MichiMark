import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../adapter/travel_expense_overview_adapter.dart';
import '../draft/overview_draft.dart';
import '../projection/moving_cost_overview_projection.dart';

/// OverviewのDelegate（Phase 1はなし）
sealed class OverviewDelegate extends Equatable {
  const OverviewDelegate();
}

// ---------------------------------------------------------------------------

/// EventDetailOverviewState
class EventDetailOverviewState extends Equatable {
  /// 対象イベントID
  final OverviewDraft draft;

  /// 現在有効なTopicConfig（EventDetailBlocから伝播）
  final TopicConfig topicConfig;

  /// movingCost用Projection。集計完了後にnon-null
  final MovingCostOverviewProjection? movingCostProjection;

  /// travelExpense用Projection。集計完了後にnon-null
  final TravelExpenseOverviewProjection? travelExpenseProjection;

  /// 集計処理中フラグ
  final bool isLoading;

  /// エラーメッセージ
  final String? errorMessage;

  /// 遷移意図の通知（Phase 1はnull固定）
  final OverviewDelegate? delegate;

  const EventDetailOverviewState({
    required this.draft,
    required this.topicConfig,
    this.movingCostProjection,
    this.travelExpenseProjection,
    this.isLoading = false,
    this.errorMessage,
    this.delegate,
  });

  EventDetailOverviewState copyWith({
    OverviewDraft? draft,
    TopicConfig? topicConfig,
    MovingCostOverviewProjection? movingCostProjection,
    TravelExpenseOverviewProjection? travelExpenseProjection,
    bool? isLoading,
    String? errorMessage,
    OverviewDelegate? delegate,
    bool clearMovingCostProjection = false,
    bool clearTravelExpenseProjection = false,
    bool clearErrorMessage = false,
  }) {
    return EventDetailOverviewState(
      draft: draft ?? this.draft,
      topicConfig: topicConfig ?? this.topicConfig,
      movingCostProjection: clearMovingCostProjection
          ? null
          : (movingCostProjection ?? this.movingCostProjection),
      travelExpenseProjection: clearTravelExpenseProjection
          ? null
          : (travelExpenseProjection ?? this.travelExpenseProjection),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      delegate: delegate,
    );
  }

  @override
  List<Object?> get props => [
        draft,
        topicConfig,
        movingCostProjection,
        travelExpenseProjection,
        isLoading,
        errorMessage,
        delegate,
      ];
}
