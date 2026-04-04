import 'package:equatable/equatable.dart';
import '../../../domain/aggregation/aggregation_filter.dart';

sealed class AggregationEvent extends Equatable {
  const AggregationEvent();
}

/// 画面表示時: マスターデータを読み込み、初期フィルタ（今月）で集計を実行する
class AggregationStarted extends AggregationEvent {
  const AggregationStarted();

  @override
  List<Object?> get props => [];
}

/// 期間プリセットまたは任意期間の選択時
class AggregationDateRangeChanged extends AggregationEvent {
  final AggregationDateRange range;
  const AggregationDateRangeChanged(this.range);

  @override
  List<Object?> get props => [range];
}

/// タグ選択・解除時
class AggregationTagFilterChanged extends AggregationEvent {
  final Set<String> tagIds;
  const AggregationTagFilterChanged(this.tagIds);

  @override
  List<Object?> get props => [tagIds];
}

/// メンバー選択・解除時
class AggregationMemberFilterChanged extends AggregationEvent {
  final Set<String> memberIds;
  const AggregationMemberFilterChanged(this.memberIds);

  @override
  List<Object?> get props => [memberIds];
}

/// Trans選択・解除時
class AggregationTransFilterChanged extends AggregationEvent {
  final String? transId;
  const AggregationTransFilterChanged(this.transId);

  @override
  List<Object?> get props => [transId];
}

/// Topic選択・解除時
class AggregationTopicFilterChanged extends AggregationEvent {
  final String? topicId;
  const AggregationTopicFilterChanged(this.topicId);

  @override
  List<Object?> get props => [topicId];
}

/// フィルタリセットボタン押下
class AggregationFilterCleared extends AggregationEvent {
  const AggregationFilterCleared();

  @override
  List<Object?> get props => [];
}
