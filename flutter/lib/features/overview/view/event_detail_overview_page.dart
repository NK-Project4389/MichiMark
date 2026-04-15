import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/overview_bloc.dart';
import '../bloc/overview_state.dart';
import 'moving_cost_overview_view.dart';
import 'travel_expense_overview_view.dart';
import 'visit_work_overview_view.dart';

class EventDetailOverviewPage extends StatelessWidget {
  const EventDetailOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventDetailOverviewBloc, EventDetailOverviewState>(
      listener: (context, state) {
        // Phase 1はDelegateなし
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final errorMessage = state.errorMessage;
        if (errorMessage != null) {
          return Center(child: Text('エラー: $errorMessage'));
        }

        final visitWork = state.visitWorkProjection;
        if (visitWork != null) {
          return VisitWorkOverviewView(projection: visitWork);
        }

        final movingCost = state.movingCostProjection;
        if (movingCost != null) {
          return MovingCostOverviewView(projection: movingCost);
        }

        final travelExpense = state.travelExpenseProjection;
        if (travelExpense != null) {
          return TravelExpenseOverviewView(projection: travelExpense);
        }

        return const Center(child: Text('集計データがありません'));
      },
    );
  }
}
