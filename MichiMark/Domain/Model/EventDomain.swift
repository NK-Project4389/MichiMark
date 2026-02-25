import Foundation

struct EventDomain: Equatable, Sendable {
    let id: EventID
    var eventName: String/// 入力必須（Stateでは空欄許可）
    var trans: TransDomain?/// 交通手段（必須）
    var members: [MemberDomain]?/// メンバー（空配列可だが、設計上は必須）
    var tags: [TagDomain]?/// タグ（空配列可）
    var kmPerGas: Int?/// 単位: 0.1km/L（10倍値）
    var pricePerGas: Int?/// 単位: 1円/L
    var payMember: MemberDomain?/// ガソリン支払者
    var markLinks: [MarkLinkDomain]?/// マーク/リンク（空配列可）
    var payments: [PaymentDomain]?/// 支払情報（空配列可）
    var isDeleted: Bool/// 論理削除
    ///schemaVersionはAdapterで定義
    let createdAt: Date/// 登録日（初回のみ設定）
    var updatedAt: Date/// 更新日（保存時更新）

    init(
        id: EventID,
        eventName: String,
        trans: TransDomain? = nil,
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

extension EventDomain {

    func updatingBasicInfo(
        from draft: BasicInfoDraft
    ) -> EventDomain {

        var updated = self
        updated.eventName = draft.eventName

        if let km = Double(draft.kmPerGas) {
            updated.kmPerGas = Int(km * 10)
        } else {
            updated.kmPerGas = nil
        }

        updated.pricePerGas = Int(draft.pricePerGas)
        updated.updatedAt = Date()
        return updated
    }

    mutating func addPayment(_ payment: PaymentDomain) {
        var updatedPayment = payment
        let nextSeq = (payments?.map(\.paymentSeq).max() ?? 0) + 1
        if updatedPayment.paymentSeq <= 0 {
            updatedPayment.paymentSeq = nextSeq
        }
        if payments == nil {
            payments = []
        }
        payments?.append(updatedPayment)
        updatedAt = Date()
    }
}
