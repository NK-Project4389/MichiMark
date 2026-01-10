public struct TransItemProjection: Identifiable, Equatable {
    public let id: TransID
    public let transName: String
    public let kmPerGas: Int?
    public let displayKmPerGas: String
    public let meterValue: Int?
    public let displayMeterValue: String
    public let isVisible: Bool
    
    init(domain: TransDomain) {
        self.id = domain.id
        self.transName = domain.transName
        self.kmPerGas = domain.kmPerGas
        if let kmPerGas = domain.kmPerGas {
            self.displayKmPerGas = "\(Double(kmPerGas) / 10) km/L"
        } else {
            self.displayKmPerGas = "未設定"
        }
        self.meterValue = domain.meterValue
        self.displayMeterValue = domain.meterValue.map { "\($0) km" } ?? "未設定"
        self.isVisible = domain.isVisible
    }
}
