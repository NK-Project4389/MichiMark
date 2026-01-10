import SwiftData
import Foundation

@Model
final class TagModel {

    @Attribute(.unique)
    var id: UUID

    var tagName: String

    var isVisible: Bool
    var isDeleted: Bool
    var schemaVersion: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        tagName: String,
        isVisible: Bool = true,
        isDeleted: Bool = false,
        schemaVersion: Int,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.tagName = tagName
        self.isVisible = isVisible
        self.isDeleted = isDeleted
        self.schemaVersion = schemaVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
