import 'package:intl/intl.dart';
import '../domain/transaction/event/event_domain.dart';
import '../features/event_list/projection/event_list_projection.dart';

/// EventList の Domain → Projection 変換
class EventListAdapter {
  EventListAdapter._();

  static final _dateFormat = DateFormat('yyyy/MM/dd');

  /// [EventDomain] のリストを [EventListProjection] に変換する
  static EventListProjection toProjection(List<EventDomain> events) {
    final items = events.map(_toSummaryItem).toList();
    return EventListProjection(events: items);
  }

  static EventSummaryItemProjection _toSummaryItem(EventDomain event) {
    final visibleMarkLinks = event.markLinks
        .where((ml) => !ml.isDeleted)
        .toList()
      ..sort((a, b) => a.markLinkSeq.compareTo(b.markLinkSeq));

    final firstDate = visibleMarkLinks.isNotEmpty
        ? _dateFormat.format(visibleMarkLinks.first.markLinkDate)
        : '';

    final lastDate = visibleMarkLinks.length > 1
        ? _dateFormat.format(visibleMarkLinks.last.markLinkDate)
        : '';

    return EventSummaryItemProjection(
      id: event.id,
      eventName: event.eventName,
      displayFromDate: firstDate,
      displayToDate: lastDate,
    );
  }
}
