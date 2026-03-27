import '../../../domain/transaction/event/event_domain.dart';
import '../../event_repository.dart';
import '../../repository_error.dart';

/// EventRepository の InMemory 実装（drift 実装前の仮実装）
class InMemoryEventRepository implements EventRepository {
  final List<EventDomain> _items = [];

  @override
  Future<List<EventDomain>> fetchAll() async =>
      _items.where((e) => !e.isDeleted).toList();

  @override
  Future<EventDomain> fetch(String id) async {
    final event =
        _items.where((e) => e.id == id && !e.isDeleted).firstOrNull;
    if (event == null) throw NotFoundError(id);
    return event;
  }

  @override
  Future<void> save(EventDomain event) async {
    final index = _items.indexWhere((e) => e.id == event.id);
    if (index >= 0) {
      _items[index] = event;
    } else {
      _items.add(event);
    }
  }

  @override
  Future<void> delete(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(isDeleted: true);
    }
  }
}
