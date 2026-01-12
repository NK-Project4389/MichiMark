import Foundation

public struct ActionDraft: Equatable, Sendable {
    var actionName: String
    var isVisible: Bool

    init(projection: ActionItemProjection) {
        self.actionName = projection.actionName
        self.isVisible = projection.isVisible
    }
}
