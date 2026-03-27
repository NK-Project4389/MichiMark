import '../../../domain/master/action/action_domain.dart';
import '../../action_repository.dart';

/// ActionRepository の InMemory 実装（drift 実装前の仮実装）
class InMemoryActionRepository implements ActionRepository {
  final List<ActionDomain> _items = [];

  @override
  Future<List<ActionDomain>> fetchAll() async =>
      _items.where((a) => !a.isDeleted).toList();

  @override
  Future<void> save(ActionDomain action) async {
    final index = _items.indexWhere((a) => a.id == action.id);
    if (index >= 0) {
      _items[index] = action;
    } else {
      _items.add(action);
    }
  }
}
