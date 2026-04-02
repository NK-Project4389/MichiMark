import '../../../domain/master/trans/trans_domain.dart';
import '../../trans_repository.dart';

/// TransRepository の InMemory 実装（drift 実装前の仮実装）
class InMemoryTransRepository implements TransRepository {
  final List<TransDomain> _items;

  InMemoryTransRepository({List<TransDomain> initialItems = const []})
      : _items = List.of(initialItems);

  @override
  Future<List<TransDomain>> fetchAll() async =>
      _items.where((t) => !t.isDeleted).toList();

  @override
  Future<void> save(TransDomain trans) async {
    final index = _items.indexWhere((t) => t.id == trans.id);
    if (index >= 0) {
      _items[index] = trans;
    } else {
      _items.add(trans);
    }
  }
}
