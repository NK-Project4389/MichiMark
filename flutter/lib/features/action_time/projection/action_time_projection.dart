import 'package:equatable/equatable.dart';

/// ログ1件の表示用Projection
class ActionTimeLogProjection extends Equatable {
  final String id;
  final String actionName;

  /// 有効時間（adjustedAt ?? timestamp）の HH:mm 表示
  final String timestampLabel;
  final String transitionLabel;

  /// adjustedAt != null の場合 true。編集アイコン表示に使用
  final bool isAdjusted;

  const ActionTimeLogProjection({
    required this.id,
    required this.actionName,
    required this.timestampLabel,
    required this.transitionLabel,
    this.isAdjusted = false,
  });

  @override
  List<Object?> get props => [id, actionName, timestampLabel, transitionLabel, isAdjusted];
}

/// アクションボタン1件の表示用Projection
class ActionButtonProjection extends Equatable {
  /// アクションID
  final String actionId;

  /// アクション名（表示用）
  final String actionName;

  /// 直近の押下時刻（HH:mm形式）。履歴なし時はnull
  final String? lastLoggedTimeLabel;

  /// 最後に押したアクションかどうか（アクティブ状態の表示制御に使用）
  final bool isLastPressed;

  const ActionButtonProjection({
    required this.actionId,
    required this.actionName,
    this.lastLoggedTimeLabel,
    this.isLastPressed = false,
  });

  @override
  List<Object?> get props => [actionId, actionName, lastLoggedTimeLabel, isLastPressed];
}

/// ActionTime表示用Projection
class ActionTimeProjection extends Equatable {
  /// 現在状態の表示文字列（例: 「作業中」）
  final String currentStateLabel;

  /// タイムライン表示用ログ一覧
  final List<ActionTimeLogProjection> logItems;

  /// 現在休憩中かどうか
  final bool isBreakActive;

  /// アクションボタン表示用Projection一覧。表示順はTopicConfig.markActions順に従う
  final List<ActionButtonProjection> buttonItems;

  const ActionTimeProjection({
    required this.currentStateLabel,
    required this.logItems,
    required this.isBreakActive,
    this.buttonItems = const [],
  });

  @override
  List<Object?> get props => [currentStateLabel, logItems, isBreakActive, buttonItems];
}
