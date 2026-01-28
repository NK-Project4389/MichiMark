import SwiftData
import Foundation

@Model
final class MarkLinkModel {

    @Attribute(.unique)
    var id: UUID

    var sortOrder: Int
    var typeRawValue: String   // enum 永続用

    var date: Date
    var name: String?
    
    @Relationship(deleteRule: .nullify)
    var members: [MemberModel]
    
    var meterValue: Int?
    var distanceValue: Int?

    @Relationship(deleteRule: .nullify)
    var actions: [ActionModel]

    var memo: String?

    // Fuel
    var isFuel: Bool
    var pricePerGas: Int?
    /// 単位: 0.1L（10倍値）
    var gasQuantity: Int?
    var gasPrice: Int?

    // System
    var isDeleted: Bool
    var schemaVersion: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        sortOrder: Int,
        typeRawValue: String,
        date: Date,
        name: String? = nil,
        members: [MemberModel] = [],
        meterValue: Int? = nil,
        distanceValue: Int? = nil,
        actions: [ActionModel] = [],
        memo: String? = nil,
        isFuel: Bool,
        pricePerGas: Int? = nil,
        gasQuantity: Int? = nil,
        gasPrice: Int? = nil,
        isDeleted: Bool = false,
        schemaVersion: Int,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.sortOrder = sortOrder
        self.typeRawValue = typeRawValue
        self.date = date
        self.name = name
        self.members = members
        self.meterValue = meterValue
        self.distanceValue = distanceValue
        self.actions = actions
        self.memo = memo
        self.isFuel = isFuel
        self.pricePerGas = pricePerGas
        self.gasQuantity = gasQuantity
        self.gasPrice = gasPrice
        self.isDeleted = isDeleted
        self.schemaVersion = schemaVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
