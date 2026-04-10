import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../adapter/aggregation_service.dart';
import '../../../adapter/event_detail_overview_adapter.dart';
import '../../../adapter/travel_expense_overview_adapter.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../domain/transaction/event/event_domain.dart';
import '../draft/overview_draft.dart';
import 'overview_event.dart';
import 'overview_state.dart';

/// EventDetailOverviewBloc
/// TopicConfigに応じて表示モードを切り替え、適切なAdapterを呼び出す。
/// 集計ロジック・収支バランス算出はAdapterに委譲する。
class EventDetailOverviewBloc
    extends Bloc<OverviewEvent, EventDetailOverviewState> {
  EventDetailOverviewBloc({
    required AggregationService aggregationService,
  })  : _aggregationService = aggregationService,
        super(EventDetailOverviewState(
          draft: const OverviewDraft(eventId: ''),
          topicConfig: TopicConfig.fromTopicType(null),
          isLoading: false,
        )) {
    on<OverviewStarted>(_onStarted);
    on<OverviewTopicConfigUpdated>(_onTopicConfigUpdated);
  }

  final AggregationService _aggregationService;

  Future<void> _onStarted(
    OverviewStarted event,
    Emitter<EventDetailOverviewState> emit,
  ) async {
    emit(state.copyWith(
      draft: OverviewDraft(eventId: event.event.id),
      topicConfig: event.topicConfig,
      isLoading: true,
      clearMovingCostProjection: true,
      clearTravelExpenseProjection: true,
      clearErrorMessage: true,
    ));

    await _runAggregation(event.event, event.topicConfig, emit);
  }

  Future<void> _onTopicConfigUpdated(
    OverviewTopicConfigUpdated event,
    Emitter<EventDetailOverviewState> emit,
  ) async {
    emit(state.copyWith(
      topicConfig: event.config,
      isLoading: true,
      clearMovingCostProjection: true,
      clearTravelExpenseProjection: true,
      clearErrorMessage: true,
    ));

    await _runAggregation(event.event, event.config, emit);
  }

  Future<void> _runAggregation(
    EventDomain eventDomain,
    TopicConfig topicConfig,
    Emitter<EventDetailOverviewState> emit,
  ) async {
    try {
      // TopicConfigのshowLinkDistanceフラグで判定（movingCost/movingCostEstimated両方がtrue）
      if (topicConfig.showLinkDistance) {
        // movingCost / movingCostEstimated 相当
        final result = await _aggregationService.aggregateEvent(eventDomain);
        final projection =
            EventDetailOverviewAdapter.toMovingCostProjection(result, event: eventDomain);
        emit(state.copyWith(
          isLoading: false,
          movingCostProjection: projection,
          clearTravelExpenseProjection: true,
        ));
      } else {
        // travelExpense相当
        final projection =
            TravelExpenseOverviewAdapter.toProjection(eventDomain);
        emit(state.copyWith(
          isLoading: false,
          travelExpenseProjection: projection,
          clearMovingCostProjection: true,
        ));
      }
    } on Exception catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
