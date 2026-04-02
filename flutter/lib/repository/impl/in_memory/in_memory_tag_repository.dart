import '../../../domain/master/tag/tag_domain.dart';
import '../../tag_repository.dart';

/// TagRepository の InMemory 実装（drift 実装前の仮実装）
class InMemoryTagRepository implements TagRepository {
  final List<TagDomain> _items;

  InMemoryTagRepository({List<TagDomain> initialItems = const []})
      : _items = List.of(initialItems);

  @override
  Future<List<TagDomain>> fetchAll() async =>
      _items.where((t) => !t.isDeleted).toList();

  @override
  Future<void> save(TagDomain tag) async {
    final index = _items.indexWhere((t) => t.id == tag.id);
    if (index >= 0) {
      _items[index] = tag;
    } else {
      _items.add(tag);
    }
  }
}
