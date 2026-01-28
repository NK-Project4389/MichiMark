public struct BasicInfoProjection: Equatable {
    public let id: EventID

    public let eventName: String// イベント
    public let trans: TransItemProjection?// 交通手段（単数表示想定）
    public let tags: [TagItemProjection]// タグ（複数）
    public let members: [MemberItemProjection]//メンバー（複数）
    public let kmPerGas: Int?// 燃費
    public let displayKmPerGas: String
    public let pricePerGas: Int?// ガソリン単価
    public let displayPricePerGas: String
    public let payMember: MemberItemProjection?// 支払者
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
