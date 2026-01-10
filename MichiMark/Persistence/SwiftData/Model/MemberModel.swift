import SwiftData
import Foundation

@Model
final class MemberModel {

    @Attribute(.unique)
    var id: UUID

    var memberName: String
    var mailAddress: String?

    var isVisible: Bool
    var isDeleted: Bool
    var schemaVersion: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        memberName: String,
        mailAddress: String? = nil,
        isVisible: Bool = true,
        isDeleted: Bool = false,
        schemaVersion: Int,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.memberName = memberName
        self.mailAddress = mailAddress
        self.isVisible = isVisible
        self.isDeleted = isDeleted
        self.schemaVersion = schemaVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
