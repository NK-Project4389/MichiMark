import Foundation

public struct ActionDraft: Equatable {
    var actionName: String
    var isVisible: Bool

    init(projection: ActionItemProjection) {
        self.actionName = projection.actionName
        self.isVisible = projection.isVisible
    }
}
