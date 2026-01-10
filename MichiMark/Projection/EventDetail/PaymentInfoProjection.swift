public struct PaymentInfoProjection: Equatable {
    public let items: [PaymentItemProjection]
    public let displayTotalAmount: String
}

extension PaymentInfoProjection {
    static var empty: Self{
        Self(
            items: [],
            displayTotalAmount: "0円"
        )
    }
}
