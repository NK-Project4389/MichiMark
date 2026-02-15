import Foundation

struct PaymentDraft: Equatable {
    var payMemberID: MemberID?
    var payMemberName: String?
    var splitMemberIDs: Set<MemberID>
    var splitMemberNames: [MemberID: String]
}

extension PaymentDraft {
    init(projection: PaymentItemProjection) {
        self.payMemberID = projection.payer.id
        self.payMemberName = projection.payer.memberName
        self.splitMemberIDs = Set(projection.splitMembers.map(\.id))
        self.splitMemberNames = Dictionary(
            uniqueKeysWithValues: projection.splitMembers.map { ($0.id, $0.memberName) }
        )
    }
}
