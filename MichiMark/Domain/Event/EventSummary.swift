import Foundation

public struct EventSummary: Identifiable, Equatable, Sendable {
    public let id: EventID
    public let eventDate: Date
    public let eventName: String

    public init(
        id: EventID,
        eventDate: Date,
        eventName: String
    ) {
        self.id = id
        self.eventDate = eventDate
        self.eventName = eventName
    }
}
