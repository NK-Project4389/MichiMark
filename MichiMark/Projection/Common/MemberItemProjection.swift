public struct MemberItemProjection: Identifiable, Equatable {
    public let id: MemberID
    public let memberName: String
    public let mailAddress: String?
    public let isVisible: Bool
}
