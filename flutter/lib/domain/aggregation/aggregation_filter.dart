import 'package:equatable/equatable.dart';

/// 集計対象の期間指定を表す sealed class
sealed class AggregationDateRange extends Equatable {
  const AggregationDateRange();
}

/// 現在月の1日〜月末
class ThisMonth extends AggregationDateRange {
  const ThisMonth();

  @override
  List<Object?> get props => [];
}

/// 前月の1日〜月末
class LastMonth extends AggregationDateRange {
  const LastMonth();

  @override
  List<Object?> get props => [];
}

/// ユーザー指定の任意期間
class CustomRange extends AggregationDateRange {
  final DateTime startDate;
  final DateTime endDate;

  const CustomRange({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

// ---------------------------------------------------------------------------

/// 集計対象Eventを絞り込むフィルタ条件を表す値オブジェクト
class AggregationFilter extends Equatable {
  /// 集計対象の期間指定（必須）
  final AggregationDateRange dateRange;

  /// 絞り込むTagIdのSet。空Setはフィルタなし
  final Set<String> tagIds;

  /// 絞り込むMemberIdのSet。空Setはフィルタなし
  final Set<String> memberIds;

  /// 絞り込むTransId。nullはフィルタなし
  final String? transId;

  /// 絞り込むTopicId。nullはフィルタなし
  final String? topicId;

  const AggregationFilter({
    required this.dateRange,
    this.tagIds = const {},
    this.memberIds = const {},
    this.transId,
    this.topicId,
  });

  AggregationFilter copyWith({
    AggregationDateRange? dateRange,
    Set<String>? tagIds,
    Set<String>? memberIds,
    String? transId,
    String? topicId,
    bool clearTransId = false,
    bool clearTopicId = false,
  }) {
    return AggregationFilter(
      dateRange: dateRange ?? this.dateRange,
      tagIds: tagIds ?? this.tagIds,
      memberIds: memberIds ?? this.memberIds,
      transId: clearTransId ? null : (transId ?? this.transId),
      topicId: clearTopicId ? null : (topicId ?? this.topicId),
    );
  }

  @override
  List<Object?> get props => [dateRange, tagIds, memberIds, transId, topicId];
}
