public struct EventSummaryItemProjection: Identifiable, Equatable {
    public let id: EventID
    public let eventName: String
    public let displayFromDate: String
    public let displayToDate: String
}
