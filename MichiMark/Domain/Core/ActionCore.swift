import Foundation

struct ActionCore: Equatable {
    let id: ActionID

    var actionName: String

    var isVisible: Bool
    var isDeleted: Bool

    var schemaVersion: Int
    let createdAt: Date
    var updatedAt: Date
}
