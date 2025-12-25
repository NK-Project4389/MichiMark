import Foundation

struct TransInfo: Identifiable, Equatable, Sendable {
    public let id: TransID
    public let transName: String
    public let isVisible: Bool
    
    public init(
        id: TransID,
        transName: String,
        isVisible: Bool
    ) {
        self.id = id
        self.transName = transName
        self.isVisible = isVisible
    }
}
