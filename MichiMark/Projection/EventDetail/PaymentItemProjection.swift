public struct PaymentItemProjection: Identifiable, Equatable {
    public let id: PaymentID
    public let displayAmount: String
    public let payer: MemberItemProjection
    public let splitMembers: [MemberItemProjection]
    public let memo: String?
}
