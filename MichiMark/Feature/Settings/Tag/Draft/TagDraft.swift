import Foundation

public struct TagDraft: Equatable, Sendable {
    var tagName: String
    var isVisible: Bool
    var isHidden: Bool {
        get { !isVisible }
        set { isVisible = !newValue }
    }

    init(projection: TagItemProjection) {
        self.tagName = projection.tagName
        self.isVisible = projection.isVisible
    }
}
