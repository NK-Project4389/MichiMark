public struct TransItemProjection: Identifiable, Equatable {
    public let id: TransID
    public let transName: String
    public let displayKmPerGas: String
    public let displayMeterValue: String
    public let isVisible: Bool
}
