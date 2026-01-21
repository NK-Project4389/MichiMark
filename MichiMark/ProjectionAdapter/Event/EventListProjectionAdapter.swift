import Foundation

struct EventListProjectionAdapter {

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()

    func adapt(events: [EventDomain]) -> EventListProjection {

        let items = events
            .filter { !$0.isDeleted }
            .sorted { $0.createdAt > $1.createdAt }
            .map { adaptItem(event: $0) }

        return EventListProjection(events: items)
    }

    // MARK: - Private

    private func adaptItem(event: EventDomain) -> EventSummaryItemProjection {

        let validMarkLinks = event.markLinks?
            .filter { !$0.isDeleted }

        let fromDate = validMarkLinks?
            .map { $0.markLinkDate }
            .min() ?? event.createdAt

        let toDate = validMarkLinks?
            .map { $0.markLinkDate }
            .max() ?? event.createdAt

        return EventSummaryItemProjection(
            id: event.id,
            eventName: event.eventName,
            displayFromDate: dateFormatter.string(from: fromDate),
            displayToDate: dateFormatter.string(from: toDate)
        )
    }
}
