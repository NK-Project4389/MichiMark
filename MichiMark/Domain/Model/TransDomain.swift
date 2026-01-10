import Foundation

struct TransDomain: Equatable, Sendable {
    let id: TransID

    /// 入力必須（Stateでは空欄許可）
    var transName: String

    /// 単位: 0.1km/L（10倍値）
    var kmPerGas: Int?

    /// 車両ごとの累積メーター（km）
    var meterValue: Int?

    /// True: 表示 / False: 非表示（初期値は true 想定）
    var isVisible: Bool

    /// 論理削除
    var isDeleted: Bool

    /// 登録日（初回のみ設定）
    let createdAt: Date

    /// 更新日（保存時更新）
    var updatedAt: Date

    init(
        id: TransID,
        transName: String,
        kmPerGas: Int? = nil,
        meterValue: Int? = nil,
        isVisible: Bool = true,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.transName = transName
        self.kmPerGas = kmPerGas
        self.meterValue = meterValue
        self.isVisible = isVisible
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
