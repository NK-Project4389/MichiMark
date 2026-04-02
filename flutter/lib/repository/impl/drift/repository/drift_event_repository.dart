import '../../../../domain/transaction/event/event_domain.dart';
import '../../../event_repository.dart';
import '../../../repository_error.dart';
import '../dao/event_dao.dart';

class DriftEventRepository implements EventRepository {
  final EventDao _dao;

  DriftEventRepository(this._dao);

  @override
  Future<List<EventDomain>> fetchAll() async => _dao.fetchAll();

  @override
  Future<EventDomain> fetch(String id) async {
    final event = await _dao.fetchById(id);
    if (event == null) throw NotFoundError(id);
    return event;
  }

  @override
  Future<void> save(EventDomain event) async {
    try {
      await _dao.saveEvent(event);
    } on Exception catch (e) {
      throw SaveFailedError(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dao.deleteEvent(id);
    } on Exception catch (e) {
      throw SaveFailedError(e);
    }
  }
}
