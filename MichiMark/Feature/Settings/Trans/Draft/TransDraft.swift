import Foundation

public struct TransDraft: Equatable {
    var transName: String
    var kmPerGas: Int
    var displayKmPerGas: String
    var meterValue: Int
    var displayMeterValue: String
    var isVisible: Bool

    init(projection: TransItemProjection) {
        self.transName = projection.transName
        self.kmPerGas = projection.kmPerGas ?? 0
        self.displayKmPerGas = projection.displayKmPerGas
        self.meterValue = projection.meterValue ?? 0
        self.displayMeterValue = projection.displayMeterValue
        self.isVisible = projection.isVisible
    }
}
