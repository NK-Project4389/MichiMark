import Foundation

struct ActionInfo: Identifiable, Equatable, Sendable {
    public let id: ActionID
    public let actionName: String
    public let isVisible: Bool
    
    public init(
        id: MemberID,
        actionName: String,
        isVisible: Bool
    ) {
        self.id = id
        self.actionName = actionName
        self.isVisible = isVisible
    }
}
