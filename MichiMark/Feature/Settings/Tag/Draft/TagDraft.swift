import Foundation

public struct TagDraft: Equatable {
    var tagName: String
    var isVisible: Bool

    init(projection: TagItemProjection) {
        self.tagName = projection.tagName
        self.isVisible = projection.isVisible
    }
}
