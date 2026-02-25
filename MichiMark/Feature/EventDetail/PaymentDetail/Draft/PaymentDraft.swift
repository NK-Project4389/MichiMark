import Foundation

struct PaymentDraft: Equatable {
    var payMemberID: MemberID?
    var payMemberName: String?
    var splitMemberIDs: Set<MemberID>
    var splitMemberNames: [MemberID: String]
    var paymentAmount: String
    var paymentMemo: String
}

extension PaymentDraft {
    init(projection: PaymentItemProjection) {
        self.payMemberID = projection.payer.id
        self.payMemberName = projection.payer.memberName
        self.splitMemberIDs = Set(projection.splitMembers.map(\.id))
        self.splitMemberNames = Dictionary(
            uniqueKeysWithValues: projection.splitMembers.map { ($0.id, $0.memberName) }
        )
        self.paymentAmount = String(
            projection.displayAmount.filter { $0.isNumber }
        )
        self.paymentMemo = projection.memo ?? ""
    }
}

extension PaymentDraft {
    static func initial() -> Self {
        PaymentDraft(
            payMemberID: nil,
            payMemberName: nil,
            splitMemberIDs: [],
            splitMemberNames: [:],
            paymentAmount: "",
            paymentMemo: ""
        )
    }

    func toDomain(
        id: PaymentID = PaymentID(),
        paymentSeq: Int = 0,
        now: Date = Date()
    ) -> PaymentDomain {
        let amount = Int(paymentAmount) ?? 0
        let memo = paymentMemo.isEmpty ? nil : paymentMemo
        let payMember = MemberDomain(
            id: payMemberID ?? MemberID(),
            memberName: payMemberName ?? ""
        )
        let splitMembers = splitMemberIDs.map { id in
            MemberDomain(
                id: id,
                memberName: splitMemberNames[id] ?? ""
            )
        }
        return PaymentDomain(
            id: id,
            paymentSeq: paymentSeq,
            paymentAmount: amount,
            paymentMember: payMember,
            splitMembers: splitMembers,
            paymentMemo: memo,
            createdAt: now,
            updatedAt: now
        )
    }
}
