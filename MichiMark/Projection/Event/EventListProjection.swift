public struct EventListProjection: Equatable {
    public let events: [EventSummaryItemProjection]

    public var isEmpty: Bool {
        events.isEmpty
    }
}
