import Foundation

struct EventDomain: Equatable, Sendable {
    let id: EventID

    /// 入力必須（Stateでは空欄許可）
    var eventName: String

    /// 交通手段（必須）
    var trans: TransDomain

    /// メンバー（空配列可だが、設計上は必須）
    var members: [MemberDomain]

    /// タグ（空配列可）
    var tags: [TagDomain]

    /// 単位: 0.1km/L（10倍値）
    var kmPerGas: Int?

    /// 単位: 1円/L
    var pricePerGas: Int?

    /// ガソリン支払者
    var payMember: MemberDomain?

    /// マーク/リンク（空配列可）
    var markLinks: [MarkLinkDomain]

    /// 支払情報（空配列可）
    var payments: [PaymentDomain]

    /// 論理削除
    var isDeleted: Bool

    /// 登録日（初回のみ設定）
    let createdAt: Date

    /// 更新日（保存時更新）
    var updatedAt: Date

    init(
        id: EventID,
        eventName: String,
        trans: TransDomain,
        members: [MemberDomain] = [],
        tags: [TagDomain] = [],
        kmPerGas: Int? = nil,
        pricePerGas: Int? = nil,
        payMember: MemberDomain? = nil,
        markLinks: [MarkLinkDomain] = [],
        payments: [PaymentDomain] = [],
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.eventName = eventName
        self.trans = trans
        self.members = members
        self.tags = tags
        self.kmPerGas = kmPerGas
        self.pricePerGas = pricePerGas
        self.payMember = payMember
        self.markLinks = markLinks
        self.payments = payments
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
