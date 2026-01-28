import Foundation

struct MemberDomain: Equatable, Sendable {
    let id: MemberID
    var memberName: String/// 入力必須（Stateでは空欄許可）
    var mailAddress: String?/// 将来拡張（共有・招待・通知など）
    var isVisible: Bool/// True: 表示 / False: 非表示（初期値は true 想定）

    var isDeleted: Bool/// 論理削除
    let createdAt: Date/// 登録日（初回のみ設定）
    var updatedAt: Date/// 更新日（保存時更新）

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
