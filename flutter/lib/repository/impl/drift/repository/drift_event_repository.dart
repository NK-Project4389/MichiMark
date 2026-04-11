import '../../../../domain/action_time/action_time_log.dart';
import '../../../../domain/aggregation/aggregation_filter.dart';
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

  // TODO: Implement when Drift schema migration is applied (schemaVersion 2)
  @override
  Future<void> saveActionTimeLog(ActionTimeLog log) async =>
      throw UnimplementedError('saveActionTimeLog not yet implemented in Drift');

  @override
  Future<void> deleteActionTimeLog(String logId) async =>
      throw UnimplementedError('deleteActionTimeLog not yet implemented in Drift');

  @override
  Future<List<ActionTimeLog>> fetchActionTimeLogs(String eventId) async =>
      throw UnimplementedError('fetchActionTimeLogs not yet implemented in Drift');

  @override
  Future<List<EventDomain>> fetchByDateRange(
    DateTime start,
    DateTime end,
  ) async =>
      throw UnimplementedError('fetchByDateRange not yet implemented in Drift');

  @override
  Future<List<EventDomain>> fetchByFilter(AggregationFilter filter) async =>
      throw UnimplementedError('fetchByFilter not yet implemented in Drift');

  @override
  Future<void> deleteMarkLink(String markLinkId) async =>
      _dao.deleteMarkLink(markLinkId);

  @override
  Future<void> deletePayment(String paymentId) =>
      _dao.deletePayment(paymentId);
}
