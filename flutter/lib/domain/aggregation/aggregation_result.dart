import 'package:equatable/equatable.dart';

/// 集計結果を表すDomainオブジェクト。永続化しない（都度算出）。
class AggregationResult extends Equatable {
  /// moving状態の所要時間合計。ActionTimeLogが不足する場合はnull
  final Duration? movingTime;

  /// working状態の所要時間合計（break_期間を除く）。ActionTimeLogが不足する場合はnull
  final Duration? workingTime;

  /// break_状態の所要時間合計。ActionTimeLogが不足する場合はnull
  final Duration? breakTime;

  /// waiting状態の所要時間合計。ActionTimeLogが不足する場合はnull
  final Duration? waitingTime;

  /// 全Linkの採用距離合計（km）。MarkLinkDomainの距離採用優先順位ルールに従う
  final int totalDistance;

  /// 全給油MarkLinkのgasQuantity合計（0.1L単位の10倍値）。給油レコードがない場合はnull
  final int? totalGasQuantity;

  /// 全給油MarkLinkのgasPrice合計（円）。給油レコードがない場合はnull
  final int? totalGasPrice;

  /// 全PaymentのpaymentAmount合計（円）。Paymentがない場合はnull
  final int? totalPayment;

  /// 集計対象のイベント件数
  final int eventCount;

  const AggregationResult({
    this.movingTime,
    this.workingTime,
    this.breakTime,
    this.waitingTime,
    required this.totalDistance,
    this.totalGasQuantity,
    this.totalGasPrice,
    this.totalPayment,
    required this.eventCount,
  });

  @override
  List<Object?> get props => [
        movingTime,
        workingTime,
        breakTime,
        waitingTime,
        totalDistance,
        totalGasQuantity,
        totalGasPrice,
        totalPayment,
        eventCount,
      ];
}
