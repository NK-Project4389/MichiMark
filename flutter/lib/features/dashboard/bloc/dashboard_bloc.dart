import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/transaction/event/event_domain.dart';
import '../../../repository/event_repository.dart';
import '../adapter/moving_cost_dashboard_adapter.dart';
import '../adapter/travel_expense_dashboard_adapter.dart';
import '../adapter/visit_work_dashboard_adapter.dart';
import '../projection/dashboard_projection.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final EventRepository _eventRepository;

  DashboardBloc({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(DashboardState.initial()) {
    on<DashboardInitialized>(_onInitialized);
    on<DashboardTopicSelected>(_onTopicSelected);
    on<DashboardMonthChanged>(_onMonthChanged);
    on<DashboardTravelEventTapped>(_onTravelEventTapped);
    on<DashboardDelegateConsumed>(_onDelegateConsumed);
  }

  Future<void> _onInitialized(
    DashboardInitialized event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final events = await _eventRepository.fetchAll();
    final available = _extractAvailableTopics(events);
    final period = DateRange.last7Days();

    if (available.isEmpty) {
      emit(state.copyWith(
        availableTopics: available,
        isLoading: false,
        clearSelectedTopic: true,
      ));
      return;
    }

    final firstTopic = available.first;
    final newState = state.copyWith(
      availableTopics: available,
      selectedTopic: firstTopic,
      period: period,
      isLoading: false,
    );

    final projected = _buildProjection(newState, events, firstTopic, period);
    emit(projected);
  }

  Future<void> _onTopicSelected(
    DashboardTopicSelected event,
    Emitter<DashboardState> emit,
  ) async {
    final events = await _eventRepository.fetchAll();
    final period = state.period;

    final updated = state.copyWith(selectedTopic: event.topic);
    final projected = _buildProjection(updated, events, event.topic, period);
    emit(projected);
  }

  Future<void> _onMonthChanged(
    DashboardMonthChanged event,
    Emitter<DashboardState> emit,
  ) async {
    final events = await _eventRepository.fetchAll();

    final projection = TravelExpenseDashboardAdapter.toProjection(
      events,
      event.month,
    );
    emit(state.copyWith(travelExpenseProjection: projection));
  }

  void _onTravelEventTapped(
    DashboardTravelEventTapped event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(
      delegate: DashboardNavigateToEventDetail(event.eventId),
    ));
  }

  void _onDelegateConsumed(
    DashboardDelegateConsumed event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(clearDelegate: true));
  }

  /// イベント一覧からデータが存在するTopicTypeを抽出する
  List<TopicType> _extractAvailableTopics(List<EventDomain> events) {
    final found = <TopicType>{};
    for (final e in events) {
      final topic = e.topic;
      if (topic == null) {
        found.add(TopicType.movingCost);
      } else {
        found.add(topic.topicType);
      }
    }
    // 表示順を固定（TopicType.values順）
    return TopicType.values.where(found.contains).toList();
  }

  /// 選択トピックに応じたProjectionをStateに設定して返す
  DashboardState _buildProjection(
    DashboardState base,
    List<EventDomain> events,
    TopicType topic,
    DateRange period,
  ) {
    switch (topic) {
      case TopicType.movingCost:
      case TopicType.movingCostEstimated:
        final projection = MovingCostDashboardAdapter.toProjection(events, period);
        return base.copyWith(
          movingCostProjection: projection,
          clearTravelExpense: true,
          clearVisitWork: true,
        );
      case TopicType.travelExpense:
        final projection = TravelExpenseDashboardAdapter.toProjection(
          events,
          DateTime.now(),
        );
        return base.copyWith(
          travelExpenseProjection: projection,
          clearMovingCost: true,
          clearVisitWork: true,
        );
      case TopicType.visitWork:
        final projection = VisitWorkDashboardAdapter.toProjection(events, period);
        return base.copyWith(
          visitWorkProjection: projection,
          clearMovingCost: true,
          clearTravelExpense: true,
        );
    }
  }
}
