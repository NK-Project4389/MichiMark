public struct EventDetailProjection: Equatable {
    public let eventId: EventID
    public let basicInfo: BasicInfoProjection
    public let michiInfo: MichiInfoListProjection
    public let paymentInfo: PaymentInfoProjection
    public let overview: OverviewProjection
}

extension EventDetailProjection {
    static func empty(eventID: EventID) -> Self {
        .init(
            eventId: eventID,
            basicInfo: .empty(eventID: eventID),
            michiInfo: .empty,
            paymentInfo: .empty,
            overview: .empty
        )
    }
}
