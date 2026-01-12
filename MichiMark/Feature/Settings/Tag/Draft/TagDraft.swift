import Foundation

public struct TagDraft: Equatable, Sendable {
    var tagName: String
    var isVisible: Bool

    init(projection: TagItemProjection) {
        self.tagName = projection.tagName
        self.isVisible = projection.isVisible
    }
}
