import Foundation

struct TagInfo: Identifiable, Equatable, Sendable {
    public let id: TagID
    public let tagName: String
    public let isVisible: Bool
    
    public init(
        id: TagID,
        tagName: String,
        isVisible: Bool
    ) {
        self.id = id
        self.tagName = tagName
        self.isVisible = isVisible
    }
}
