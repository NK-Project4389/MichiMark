import SwiftData
import Foundation

@Model
final class TransModel {

    @Attribute(.unique)
    var id: UUID

    var transName: String
    /// 単位: 0.1km/L（10倍値）
    var kmPerGas: Int?
    var meterValue: Int?

    var isVisible: Bool
    var isDeleted: Bool
    var schemaVersion: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        transName: String,
        kmPerGas: Int? = nil,
        meterValue: Int? = nil,
        isVisible: Bool = true,
        isDeleted: Bool = false,
        schemaVersion: Int,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.transName = transName
        self.kmPerGas = kmPerGas
        self.meterValue = meterValue
        self.isVisible = isVisible
        self.isDeleted = isDeleted
        self.schemaVersion = schemaVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
