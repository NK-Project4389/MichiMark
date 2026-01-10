import Foundation

struct PaymentCore: Equatable {
    let id: PaymentID

    var paymentSeq: Int
    var paymentAmount: Int

    var paymentMember: MemberCore?
    var splitMembers: [MemberCore]

    var paymentMemo: String?

    var isDeleted: Bool
    var schemaVersion: Int
    let createdAt: Date
    var updatedAt: Date
}
