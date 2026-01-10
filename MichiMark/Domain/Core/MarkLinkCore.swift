import Foundation

struct MarkLinkCore: Equatable {
    let id: MarkLinkID

    var markLinkSeq: Int
    var markLinkType: MarkOrLink
    
    var markLinkDate: Date
    var markLinkName: String?

    /// 累積メーター（km）
    var meterValue: Int?

    /// 区間距離（km）
    var distanceValue: Int?

    var actions: [ActionCore]
    var memo: String?

    var isFuel: Bool
    var pricePerGas: Int?

    /// 単位: 0.1L（10倍値）
    var gasQuantity: Int?

    var gasPrice: Int?

    var isDeleted: Bool
    var schemaVersion: Int
    let createdAt: Date
    var updatedAt: Date
}
