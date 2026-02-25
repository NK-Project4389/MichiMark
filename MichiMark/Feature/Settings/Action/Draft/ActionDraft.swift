import Foundation

public struct ActionDraft: Equatable, Sendable {
    var actionName: String
    var isVisible: Bool
    var isHidden: Bool {
        get { !isVisible }
        set { isVisible = !newValue }
    }

    init(projection: ActionItemProjection) {
        self.actionName = projection.actionName
        self.isVisible = projection.isVisible
    }
}
