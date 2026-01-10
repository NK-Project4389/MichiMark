public struct BasicInfoProjection: Equatable {
    public let id: EventID

    // イベント
    public let eventName: String

    // 交通手段（単数表示想定）
    public let trans: TransItemProjection?

    // タグ・メンバー（複数）
    public let tags: [TagItemProjection]
    public let members: [MemberItemProjection]

    // 燃費
    public let kmPerGas: Int?
    public let displayKmPerGas: String

    // ガソリン単価
    public let pricePerGas: Int?
    public let displayPricePerGas: String

    // 支払者
    public let payMember: MemberItemProjection?
}

extension BasicInfoProjection {
    static func empty(eventID: EventID) -> Self {
        .init(
            id: eventID,
            eventName: "",
            trans: nil,
            tags: [],
            members: [],
            kmPerGas: nil,
            displayKmPerGas: "",
            pricePerGas: nil,
            displayPricePerGas: "",
            payMember: nil
        )
    }
}
