import Foundation

struct TransCore: Equatable {
    let id: TransID

    var transName: String

    /// 単位: 0.1km/L（10倍値）
    var kmPerGas: Int?

    var meterValue: Int?

    var isVisible: Bool
    var isDeleted: Bool

    var schemaVersion: Int
    let createdAt: Date
    var updatedAt: Date
}
