import 'package:equatable/equatable.dart';
import '../../../domain/aggregation/aggregation_filter.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/master/tag/tag_domain.dart';
import '../../../domain/master/trans/trans_domain.dart';
import '../../../domain/topic/topic_domain.dart';

/// AggregationDraft（フィルタ選択中状態）
class AggregationDraft extends Equatable {
  /// 現在選択中のフィルタ条件
  final AggregationFilter filter;

  /// 選択可能なTag一覧
  final List<TagDomain> availableTags;

  /// 選択可能なMember一覧
  final List<MemberDomain> availableMembers;

  /// 選択可能なTrans一覧
  final List<TransDomain> availableTrans;

  /// 選択可能なTopic一覧
  final List<TopicDomain> availableTopics;

  const AggregationDraft({
    required this.filter,
    this.availableTags = const [],
    this.availableMembers = const [],
    this.availableTrans = const [],
    this.availableTopics = const [],
  });

  AggregationDraft copyWith({
    AggregationFilter? filter,
    List<TagDomain>? availableTags,
    List<MemberDomain>? availableMembers,
    List<TransDomain>? availableTrans,
    List<TopicDomain>? availableTopics,
  }) {
    return AggregationDraft(
      filter: filter ?? this.filter,
      availableTags: availableTags ?? this.availableTags,
      availableMembers: availableMembers ?? this.availableMembers,
      availableTrans: availableTrans ?? this.availableTrans,
      availableTopics: availableTopics ?? this.availableTopics,
    );
  }

  @override
  List<Object?> get props =>
      [filter, availableTags, availableMembers, availableTrans, availableTopics];
}
