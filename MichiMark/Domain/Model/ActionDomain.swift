import Foundation

struct ActionDomain: Equatable, Sendable {
    let id: ActionID

    /// 入力必須（Stateでは空欄許可）
    var actionName: String

    /// True: 表示 / False: 非表示（初期値は true 想定）
    var isVisible: Bool

    /// 論理削除
    var isDeleted: Bool

    /// 登録日（初回のみ設定）
    let createdAt: Date

    /// 更新日（保存時更新）
    var updatedAt: Date

    init(
        id: ActionID,
        actionName: String,
        isVisible: Bool = true,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.actionName = actionName
        self.isVisible = isVisible
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
