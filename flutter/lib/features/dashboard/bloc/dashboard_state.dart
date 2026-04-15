import 'package:equatable/equatable.dart';
import '../../../domain/topic/topic_domain.dart';
import '../projection/dashboard_projection.dart';
import '../projection/moving_cost_dashboard_projection.dart';
import '../projection/travel_expense_dashboard_projection.dart';
import '../projection/visit_work_dashboard_projection.dart';

/// Delegateパターン: ダッシュボードからの遷移意図
abstract class DashboardDelegate extends Equatable {
  const DashboardDelegate();
}

/// イベント詳細へ遷移
class DashboardNavigateToEventDetail extends DashboardDelegate {
  final String eventId;

  const DashboardNavigateToEventDetail(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class DashboardState extends Equatable {
  final List<TopicType> availableTopics;
  final TopicType? selectedTopic;
  final DateRange period;
  final MovingCostDashboardProjection? movingCostProjection;
  final TravelExpenseDashboardProjection? travelExpenseProjection;
  final VisitWorkDashboardProjection? visitWorkProjection;
  final bool isLoading;
  final DashboardDelegate? delegate;

  const DashboardState({
    this.availableTopics = const [],
    this.selectedTopic,
    required this.period,
    this.movingCostProjection,
    this.travelExpenseProjection,
    this.visitWorkProjection,
    this.isLoading = false,
    this.delegate,
  });

  factory DashboardState.initial() => DashboardState(
        period: DateRange.last7Days(),
      );

  DashboardState copyWith({
    List<TopicType>? availableTopics,
    TopicType? selectedTopic,
    DateRange? period,
    MovingCostDashboardProjection? movingCostProjection,
    TravelExpenseDashboardProjection? travelExpenseProjection,
    VisitWorkDashboardProjection? visitWorkProjection,
    bool? isLoading,
    DashboardDelegate? delegate,
    bool clearDelegate = false,
    bool clearMovingCost = false,
    bool clearTravelExpense = false,
    bool clearVisitWork = false,
    bool clearSelectedTopic = false,
  }) {
    return DashboardState(
      availableTopics: availableTopics ?? this.availableTopics,
      selectedTopic: clearSelectedTopic
          ? null
          : (selectedTopic ?? this.selectedTopic),
      period: period ?? this.period,
      movingCostProjection: clearMovingCost
          ? null
          : (movingCostProjection ?? this.movingCostProjection),
      travelExpenseProjection: clearTravelExpense
          ? null
          : (travelExpenseProjection ?? this.travelExpenseProjection),
      visitWorkProjection: clearVisitWork
          ? null
          : (visitWorkProjection ?? this.visitWorkProjection),
      isLoading: isLoading ?? this.isLoading,
      delegate: clearDelegate ? null : (delegate ?? this.delegate),
    );
  }

  @override
  List<Object?> get props => [
        availableTopics,
        selectedTopic,
        period,
        movingCostProjection,
        travelExpenseProjection,
        visitWorkProjection,
        isLoading,
        delegate,
      ];
}
