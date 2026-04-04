import '../../../domain/topic/topic_domain.dart';
import '../../topic_repository.dart';

/// TopicRepository の InMemory 実装（開発用）
class InMemoryTopicRepository implements TopicRepository {
  final List<TopicDomain> _items;

  InMemoryTopicRepository({List<TopicDomain> initialItems = const []})
      : _items = List.of(initialItems);

  @override
  Future<List<TopicDomain>> fetchAll() async =>
      _items.where((t) => !t.isDeleted && t.isVisible).toList();

  @override
  Future<List<TopicDomain>> fetchByType(TopicType type) async =>
      _items.where((t) => !t.isDeleted && t.topicType == type).toList();

  @override
  Future<void> save(TopicDomain topic) async {
    final index = _items.indexWhere((t) => t.id == topic.id);
    if (index >= 0) {
      _items[index] = topic;
    } else {
      _items.add(topic);
    }
  }
}
