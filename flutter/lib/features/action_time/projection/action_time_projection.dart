import 'package:equatable/equatable.dart';

/// ログ1件の表示用Projection
class ActionTimeLogProjection extends Equatable {
  final String id;
  final String actionName;
  final String timestampLabel;
  final String transitionLabel;

  const ActionTimeLogProjection({
    required this.id,
    required this.actionName,
    required this.timestampLabel,
    required this.transitionLabel,
  });

  @override
  List<Object?> get props => [id, actionName, timestampLabel, transitionLabel];
}

/// ActionTime表示用Projection
class ActionTimeProjection extends Equatable {
  /// 現在状態の表示文字列（例: 「作業中」）
  final String currentStateLabel;

  /// タイムライン表示用ログ一覧
  final List<ActionTimeLogProjection> logItems;

  /// 現在休憩中かどうか
  final bool isBreakActive;

  const ActionTimeProjection({
    required this.currentStateLabel,
    required this.logItems,
    required this.isBreakActive,
  });

  @override
  List<Object?> get props => [currentStateLabel, logItems, isBreakActive];
}
