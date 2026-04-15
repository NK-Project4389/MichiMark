import 'package:equatable/equatable.dart';
import '../action_time/action_state.dart';

/// ActionTimeLog の解釈結果として得られる1つの状態区間。
class VisitWorkSegment extends Equatable {
  final ActionState state;
  final DateTime from;
  final DateTime to;

  const VisitWorkSegment({
    required this.state,
    required this.from,
    required this.to,
  });

  Duration get duration => to.difference(from);

  @override
  List<Object?> get props => [state, from, to];
}
