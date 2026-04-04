import 'package:equatable/equatable.dart';

/// 集計結果の表示用Projection
class AggregationProjection extends Equatable {
  /// 集計対象イベント件数の表示文字列（例: "12件"）
  final String eventCountLabel;

  /// 移動時間合計の表示文字列（"---"含む）
  final String movingTimeLabel;

  /// 作業時間合計の表示文字列
  final String workingTimeLabel;

  /// 休憩時間合計の表示文字列
  final String breakTimeLabel;

  /// 総走行距離の表示文字列
  final String totalDistanceLabel;

  /// ガソリン代合計の表示文字列
  final String totalGasPriceLabel;

  /// 経費合計の表示文字列
  final String totalPaymentLabel;

  /// 現在のフィルタ内容のサマリー表示文字列（例: "今月 / タグ: 仕事"）
  final String filterSummaryLabel;

  const AggregationProjection({
    required this.eventCountLabel,
    required this.movingTimeLabel,
    required this.workingTimeLabel,
    required this.breakTimeLabel,
    required this.totalDistanceLabel,
    required this.totalGasPriceLabel,
    required this.totalPaymentLabel,
    required this.filterSummaryLabel,
  });

  @override
  List<Object?> get props => [
        eventCountLabel,
        movingTimeLabel,
        workingTimeLabel,
        breakTimeLabel,
        totalDistanceLabel,
        totalGasPriceLabel,
        totalPaymentLabel,
        filterSummaryLabel,
      ];
}
