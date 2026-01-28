import Foundation

struct TransDomain: Equatable, Sendable {
    let id: TransID
    var transName: String/// 入力必須（Stateでは空欄許可）
    var kmPerGas: Int?/// 単位: 0.1km/L（10倍値）
    var meterValue: Int?/// 車両ごとの累積メーター（km）
    var isVisible: Bool///True: 表示 / False: 非表示（初期値は true 想定）
    
    var isDeleted: Bool/// 論理削除
    let createdAt: Date/// 登録日（初回のみ設定）
    var updatedAt: Date/// 更新日（保存時更新）

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
