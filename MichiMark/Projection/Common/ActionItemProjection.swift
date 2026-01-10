public struct ActionItemProjection: Identifiable, Equatable {
    public let id: ActionID
    public let actionName: String
    public let isVisible: Bool

    init(domain: ActionDomain) {
        self.id = domain.id
        self.actionName = domain.actionName
        self.isVisible = domain.isVisible
    }
}
