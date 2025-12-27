import Foundation

struct MemberInfo: Identifiable, Equatable, Sendable {
    public let id: MemberID
    public let memberName: String
    public let isVisible: Bool
    
    public init(
        id: MemberID,
        memberName: String,
        isVisible: Bool
    ) {
        self.id = id
        self.memberName = memberName
        self.isVisible = isVisible
    }
}
