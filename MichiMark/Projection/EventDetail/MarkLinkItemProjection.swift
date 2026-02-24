import Foundation

public struct MarkLinkItemProjection: Identifiable, Equatable {
    public let id: MarkLinkID
    public let markLinkSeq: Int//表示順
    public let markLinkType: MarkOrLink//マークorリンク
    
    public let displayDate: String//日付
    public let markLinkName: String//マークリンク名
    
    
    public let members: [MemberItemProjection]//メンバー
    
    public let displayMeterValue: String?//メーター
    public let displayDistanceValue: String?//走行距離
    public let actions: [ActionItemProjection]//行動
    public let isFuel: Bool
    public let pricePerGas: Int?/// 単位: 1円/L 通過型に変換
    public let gasQuantity: Double?/// 単位: 0.1L（10倍値）
    public let gasPrice: Int?/// 単位: 1円 通過型に変換
    public let memo: String?
}

extension MarkLinkItemProjection {

    static func emptry(markLinkId: MarkLinkID) -> Self {
        .init(
            id: markLinkId,
            markLinkSeq: 0,
            markLinkType: .mark,
            displayDate: "",
            markLinkName: "",
            members: [],
            displayMeterValue: nil,
            displayDistanceValue: nil,
            actions: [],
            isFuel: false,
            pricePerGas: nil,
            gasQuantity: nil,
            gasPrice: nil,
            memo: nil
        )
    }
    
    static func dummy(
        title: String = "自宅",
        date: String = "2026/01/01",
        markLink: MarkOrLink = .mark,
        seq: Int = 0
    ) -> Self {
        .init(
            id: MarkLinkID(),
            markLinkSeq: seq,
            markLinkType: markLink,
            displayDate: date,
            markLinkName: title,
            members: [],
            displayMeterValue: "1,000km",
            displayDistanceValue: "10.6km/L",
            actions: [],
            isFuel: false,
            pricePerGas: nil,
            gasQuantity: nil,
            gasPrice: nil,
            memo: ""
        )
    }

}
