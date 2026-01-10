public struct MarkLinkItemProjection: Identifiable, Equatable {
    public let id: MarkLinkID
    public let title: String
    public let displayDate: String
    public let displayDistance: String?
    public let actions: [ActionItemProjection]
    public let isFuel: Bool
}
