import Foundation

struct MarkLinkDomain: Equatable, Sendable {
    let id: MarkLinkID
    var markLinkSeq: Int///表示順
    var markLinkType: MarkOrLink/// mark / link（初期値は .mark 想定）
    var markLinkDate: Date/// 任意の日付に設定可能
    var markLinkName: String?/// 入力必須（Stateでは空欄許可）
    var members: [MemberDomain]///メンバー（空欄列可）
    var meterValue: Int?/// 累積メーター（km）: Mark 用
    var distanceValue: Int?/// 区間距離（km）: Link 用
    var actions: [ActionDomain]/// 行動（空配列可）
    var memo: String?/// 入力必須（Stateでは空欄許可）

    /// 給油フラグ（初期値は false 想定）
    /// isFuel == false の場合、ガソリン関連項目は nil を想定（制約は Adapter/Reducer で担保）
    var isFuel: Bool
    var pricePerGas: Int?/// 単位: 1円/L
    var gasQuantity: Int?/// 単位: 0.1L（10倍値）
    var gasPrice: Int?/// 単位: 1円

    var isDeleted: Bool/// 論理削除
    let createdAt: Date/// 登録日（初回のみ設定）
    var updatedAt: Date/// 更新日（保存時更新）
    init(
        id: MarkLinkID,
        markLinkSeq: Int,
        markLinkType: MarkOrLink = .mark,
        markLinkDate: Date,
        markLinkName: String? = nil,
        members: [MemberDomain] = [],
        meterValue: Int? = nil,
        distanceValue: Int? = nil,
        actions: [ActionDomain] = [],
        memo: String? = nil,
        isFuel: Bool = false,
        pricePerGas: Int? = nil,
        gasQuantity: Int? = nil,
        gasPrice: Int? = nil,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.markLinkSeq = markLinkSeq
        self.markLinkType = markLinkType
        self.markLinkDate = markLinkDate
        self.markLinkName = markLinkName
        self.members = members
        self.meterValue = meterValue
        self.distanceValue = distanceValue
        self.actions = actions
        self.memo = memo
        self.isFuel = isFuel
        self.pricePerGas = pricePerGas
        self.gasQuantity = gasQuantity
        self.gasPrice = gasPrice
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
