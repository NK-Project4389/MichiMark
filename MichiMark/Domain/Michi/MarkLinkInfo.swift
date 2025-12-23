import Foundation

public struct MarkLinkInfo: Identifiable, Equatable, Sendable {
    public let id: MarkLinkID
    public let kind: MarkOrLink
    public let markLinkName: String

    // 将来拡張用（今は表示のみ）
    public let members: [String]
    public let meterValue: Int?
    public let distanceValue: Int?
    public let actionName: String?
    public let memo: String?
    public let fuelFlg: Bool

    public init(
        id: MarkLinkID,
        kind: MarkOrLink,
        markLinkName: String,
        members: [String] = [],
        meterValue: Int? = nil,
        distanceValue: Int? = nil,
        actionName: String? = nil,
        memo: String? = nil,
        fuelFlg: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.markLinkName = markLinkName
        self.members = members
        self.meterValue = meterValue
        self.distanceValue = distanceValue
        self.actionName = actionName
        self.memo = memo
        self.fuelFlg = fuelFlg
    }
}
