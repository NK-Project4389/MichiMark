import Foundation

struct PaymentDomain: Equatable, Sendable {
    let id: PaymentID

    /// 表示順
    var paymentSeq: Int

    /// 単位: 1円
    var paymentAmount: Int

    /// 支払メンバー（必須）
    var paymentMember: MemberDomain

    /// 割り勘メンバー（空配列可）
    var splitMembers: [MemberDomain]

    /// 入力必須（Stateでは空欄許可）
    var paymentMemo: String?

    /// 論理削除
    var isDeleted: Bool

    /// 登録日（初回のみ設定）
    let createdAt: Date

    /// 更新日（保存時更新）
    var updatedAt: Date

    init(
        id: PaymentID,
        paymentSeq: Int,
        paymentAmount: Int,
        paymentMember: MemberDomain,
        splitMembers: [MemberDomain] = [],
        paymentMemo: String? = nil,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.paymentSeq = paymentSeq
        self.paymentAmount = paymentAmount
        self.paymentMember = paymentMember
        self.splitMembers = splitMembers
        self.paymentMemo = paymentMemo
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
