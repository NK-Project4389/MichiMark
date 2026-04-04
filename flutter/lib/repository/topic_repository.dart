import '../domain/topic/topic_domain.dart';

/// Topicの永続化インターフェース
abstract interface class TopicRepository {
  /// is_deleted = false の全Topic取得
  Future<List<TopicDomain>> fetchAll();

  /// 指定typeのTopic取得
  Future<List<TopicDomain>> fetchByType(TopicType type);

  /// upsert
  Future<void> save(TopicDomain topic);
}
