import SwiftData
import Foundation

@Model
final class EventModel {

    @Attribute(.unique)
    var id: UUID

    var eventName: String

    // Relationships
    @Relationship(deleteRule: .nullify)
    var trans: TransModel?

    @Relationship(deleteRule: .nullify)
    var members: [MemberModel]

    @Relationship(deleteRule: .nullify)
    var tags: [TagModel]

    @Relationship(deleteRule: .cascade)
    var markLinks: [MarkLinkModel]

    @Relationship(deleteRule: .cascade)
    var payments: [PaymentModel]

    // Fuel
    /// 単位: 0.1km/L（10倍値）
    var kmPerGas: Int?
    var pricePerGas: Int?

    @Relationship(deleteRule: .nullify)
    var payMember: MemberModel?

    // System
    var isDeleted: Bool
    var schemaVersion: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        eventName: String,
        trans: TransModel? = nil,
        members: [MemberModel] = [],
        tags: [TagModel] = [],
        markLinks: [MarkLinkModel] = [],
        payments: [PaymentModel] = [],
        kmPerGas: Int? = nil,
        pricePerGas: Int? = nil,
        payMember: MemberModel? = nil,
        isDeleted: Bool = false,
        schemaVersion: Int,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.eventName = eventName
        self.trans = trans
        self.members = members
        self.tags = tags
        self.markLinks = markLinks
        self.payments = payments
        self.kmPerGas = kmPerGas
        self.pricePerGas = pricePerGas
        self.payMember = payMember
        self.isDeleted = isDeleted
        self.schemaVersion = schemaVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
