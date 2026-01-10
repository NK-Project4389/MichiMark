public struct MemberItemProjection: Identifiable, Equatable {
    public let id: MemberID
    public let memberName: String
    public let mailAddress: String?
    public let isVisible: Bool

    init(domain: MemberDomain) {
        self.id = domain.id
        self.memberName = domain.memberName
        self.mailAddress = domain.mailAddress
        self.isVisible = domain.isVisible
    }
}
