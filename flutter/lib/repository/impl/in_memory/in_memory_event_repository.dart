import '../../../domain/aggregation/aggregation_filter.dart';
import '../../../domain/action_time/action_time_log.dart';
import '../../../domain/transaction/event/event_domain.dart';
import '../../event_repository.dart';
import '../../repository_error.dart';

/// EventRepository の InMemory 実装（drift 実装前の仮実装）
class InMemoryEventRepository implements EventRepository {
  final List<EventDomain> _items;
  final List<ActionTimeLog> _actionTimeLogs = [];

  InMemoryEventRepository({List<EventDomain> initialItems = const []})
      : _items = List.of(initialItems);

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

  @override
  Future<void> saveActionTimeLog(ActionTimeLog log) async {
    final index = _actionTimeLogs.indexWhere((l) => l.id == log.id);
    if (index >= 0) {
      _actionTimeLogs[index] = log;
    } else {
      _actionTimeLogs.add(log);
    }
  }

  @override
  Future<void> deleteActionTimeLog(String id) async {
    final index = _actionTimeLogs.indexWhere((l) => l.id == id);
    if (index >= 0) {
      _actionTimeLogs[index] = _actionTimeLogs[index].copyWith(isDeleted: true);
    }
  }

  @override
  Future<List<ActionTimeLog>> fetchActionTimeLogs(String eventId) async {
    final logs = _actionTimeLogs
        .where((l) => l.eventId == eventId && !l.isDeleted)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return logs;
  }

  @override
  Future<List<EventDomain>> fetchByDateRange(DateTime start, DateTime end) async {
    return _items
        .where((e) =>
            !e.isDeleted &&
            !e.createdAt.isBefore(start) &&
            !e.createdAt.isAfter(end))
        .toList();
  }

  @override
  Future<void> deleteMarkLink(String markLinkId) async {
    for (var i = 0; i < _items.length; i++) {
      final event = _items[i];
      final mlIndex = event.markLinks.indexWhere((ml) => ml.id == markLinkId);
      if (mlIndex >= 0) {
        final updatedMarkLinks = List.of(event.markLinks);
        updatedMarkLinks[mlIndex] =
            updatedMarkLinks[mlIndex].copyWith(isDeleted: true);
        _items[i] = event.copyWith(markLinks: updatedMarkLinks);
        return;
      }
    }
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    for (var i = 0; i < _items.length; i++) {
      final event = _items[i];
      final payIndex = event.payments.indexWhere((p) => p.id == paymentId);
      if (payIndex >= 0) {
        final updatedPayments = List.of(event.payments);
        updatedPayments[payIndex] =
            updatedPayments[payIndex].copyWith(isDeleted: true);
        _items[i] = event.copyWith(payments: updatedPayments);
        return;
      }
    }
  }

  @override
  Future<List<EventDomain>> fetchByFilter(AggregationFilter filter) async {
    // 期間計算
    final (start, end) = _resolveDateRange(filter.dateRange);
    var results = await fetchByDateRange(start, end);

    // tagIds フィルタ（OR条件）
    if (filter.tagIds.isNotEmpty) {
      results = results
          .where((e) => e.tags.any((t) => filter.tagIds.contains(t.id)))
          .toList();
    }

    // memberIds フィルタ（OR条件）
    if (filter.memberIds.isNotEmpty) {
      results = results
          .where((e) => e.members.any((m) => filter.memberIds.contains(m.id)))
          .toList();
    }

    // transId フィルタ
    final transId = filter.transId;
    if (transId != null) {
      results = results
          .where((e) => e.trans?.id == transId)
          .toList();
    }

    // topicId フィルタ
    final topicId = filter.topicId;
    if (topicId != null) {
      results = results
          .where((e) => e.topic?.id == topicId)
          .toList();
    }

    return results;
  }

  (DateTime, DateTime) _resolveDateRange(AggregationDateRange range) {
    final now = DateTime.now();
    return switch (range) {
      ThisMonth() => (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1)),
        ),
      LastMonth() => (
          DateTime(now.year, now.month - 1, 1),
          DateTime(now.year, now.month, 1).subtract(const Duration(milliseconds: 1)),
        ),
      CustomRange(:final startDate, :final endDate) => (startDate, endDate),
    };
  }
}
