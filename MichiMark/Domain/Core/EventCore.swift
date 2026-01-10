import Foundation

struct EventCore: Equatable {
    let id: EventID

    var eventName: String

    var trans: TransCore?
    var members: [MemberCore]
    var tags: [TagCore]

    /// 単位: 0.1km/L（10倍値）
    var kmPerGas: Int?
    var pricePerGas: Int?

    var payMember: MemberCore?

    var markLinks: [MarkLinkCore]
    var payments: [PaymentCore]

    var isDeleted: Bool
    var schemaVersion: Int
    let createdAt: Date
    var updatedAt: Date
}
