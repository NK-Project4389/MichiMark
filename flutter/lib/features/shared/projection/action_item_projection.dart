import 'package:equatable/equatable.dart';

class ActionItemProjection extends Equatable {
  final String id;
  final String actionName;
  final bool isVisible;

  const ActionItemProjection({
    required this.id,
    required this.actionName,
    required this.isVisible,
  });

  @override
  List<Object?> get props => [id, actionName, isVisible];
}
