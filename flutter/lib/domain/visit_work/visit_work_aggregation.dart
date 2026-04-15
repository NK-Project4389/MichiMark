import 'package:equatable/equatable.dart';

/// 表示向けの集計値オブジェクト。Adapterで算出する。
class VisitWorkAggregation extends Equatable {
  final Duration movingDuration;
  final Duration stayingDuration; // ActionState.waiting の合計
  final Duration workingDuration;
  final Duration breakDuration;
  final Duration? onSiteDuration; // 到着〜出発の合計（出発前は null）
  final int? revenue; // 売上合計（円）。Payment 未登録は null
  final bool isOngoing;

  const VisitWorkAggregation({
    required this.movingDuration,
    required this.stayingDuration,
    required this.workingDuration,
    required this.breakDuration,
    this.onSiteDuration,
    this.revenue,
    required this.isOngoing,
  });

  /// 時給換算（売上 ÷ 作業時間）。作業時間0 or 売上null の場合は null
  int? get revenuePerHour {
    final rev = revenue;
    if (rev == null) return null;
    final hours = workingDuration.inMinutes / 60.0;
    if (hours == 0) return null;
    return (rev / hours).round();
  }

  @override
  List<Object?> get props => [
        movingDuration,
        stayingDuration,
        workingDuration,
        breakDuration,
        onSiteDuration,
        revenue,
        isOngoing,
      ];
}
