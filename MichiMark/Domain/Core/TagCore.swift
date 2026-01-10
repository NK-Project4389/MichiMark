import Foundation

struct TagCore: Equatable {
    let id: TagID

    var tagName: String

    var isVisible: Bool
    var isDeleted: Bool

    var schemaVersion: Int
    let createdAt: Date
    var updatedAt: Date
}
