import Foundation

struct MemberDomain: Equatable, Sendable {
    let id: MemberID

    /// 入力必須（Stateでは空欄許可）
    var memberName: String

    /// 将来拡張（共有・招待・通知など）
    var mailAddress: String?

    /// True: 表示 / False: 非表示（初期値は true 想定）
    var isVisible: Bool

    /// 論理削除
    var isDeleted: Bool

    /// 登録日（初回のみ設定）
    let createdAt: Date

    /// 更新日（保存時更新）
    var updatedAt: Date

    init(
        id: MemberID,
        memberName: String,
        mailAddress: String? = nil,
        isVisible: Bool = true,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.memberName = memberName
        self.mailAddress = mailAddress
        self.isVisible = isVisible
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
