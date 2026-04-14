import 'package:equatable/equatable.dart';
import '../../../adapter/travel_expense_overview_adapter.dart';

/// movingCost用 Projection。
/// AggregationResultのnullフィールドは "---" に変換済み。
class MovingCostOverviewProjection extends Equatable {
  /// 移動時間の表示文字列。算出不可の場合は "---"
  final String movingTimeLabel;

  /// 作業時間の表示文字列。算出不可の場合は "---"
  final String workingTimeLabel;

  /// 休憩時間の表示文字列。算出不可の場合は "---"
  final String breakTimeLabel;

  /// 滞留時間の表示文字列。算出不可の場合は "---"
  final String waitingTimeLabel;

  /// 総走行距離の表示文字列（例: "120km"）
  final String totalDistanceLabel;

  /// 給油量の表示文字列（例: "30.0L"、なしは "---"）
  final String totalGasQuantityLabel;

  /// ガソリン代の表示文字列（例: "5,000円"、なしは "---"）
  final String totalGasPriceLabel;

  /// 経費合計の表示文字列（例: "3,000円"、なしは "---"）
  final String totalPaymentLabel;

  /// 給油データが1件以上存在する場合 true。AggregationResult.totalGasQuantity が非nullの場合に true
  final bool hasFuelData;

  /// メンバー別収支バランス一覧。収支データがない場合は空リスト
  final List<MemberBalanceProjection> memberBalances;

  const MovingCostOverviewProjection({
    required this.movingTimeLabel,
    required this.workingTimeLabel,
    required this.breakTimeLabel,
    required this.waitingTimeLabel,
    required this.totalDistanceLabel,
    required this.totalGasQuantityLabel,
    required this.totalGasPriceLabel,
    required this.totalPaymentLabel,
    required this.hasFuelData,
    this.memberBalances = const [],
  });

  @override
  List<Object?> get props => [
        movingTimeLabel,
        workingTimeLabel,
        breakTimeLabel,
        waitingTimeLabel,
        totalDistanceLabel,
        totalGasQuantityLabel,
        totalGasPriceLabel,
        totalPaymentLabel,
        hasFuelData,
        memberBalances,
      ];
}
