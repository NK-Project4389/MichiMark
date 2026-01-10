import SwiftData
import Foundation

@Model
final class PaymentModel {

    @Attribute(.unique)
    var id: UUID

    var sortOrder: Int
    var paymentAmount: Int

    @Relationship(deleteRule: .nullify)
    var paymentMember: MemberModel?

    @Relationship(deleteRule: .nullify)
    var splitMembers: [MemberModel]

    var memo: String?

    // System
    var isDeleted: Bool
    var schemaVersion: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        sortOrder: Int,
        paymentAmount: Int,
        paymentMember: MemberModel? = nil,
        splitMembers: [MemberModel] = [],
        memo: String? = nil,
        isDeleted: Bool = false,
        schemaVersion: Int,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.sortOrder = sortOrder
        self.paymentAmount = paymentAmount
        self.paymentMember = paymentMember
        self.splitMembers = splitMembers
        self.memo = memo
        self.isDeleted = isDeleted
        self.schemaVersion = schemaVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
