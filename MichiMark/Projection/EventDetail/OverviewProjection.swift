public struct OverviewProjection: Equatable {
    public let displayTotalDistance: String
    public let displayTotalGasCost: String
}

extension OverviewProjection {
    static var empty: Self{
        Self(
            displayTotalDistance: "0km",
            displayTotalGasCost: "0円"
        )
    }
}
