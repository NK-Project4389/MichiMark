public struct ActionItemProjection: Identifiable, Equatable {
    public let id: ActionID
    public let actionName: String
    public let isVisible: Bool
}
