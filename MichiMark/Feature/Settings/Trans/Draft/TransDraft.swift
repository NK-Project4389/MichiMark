import Foundation

public struct TransDraft: Equatable, Sendable {
    var transName: String
    var displayKmPerGas: String
    var displayMeterValue: String
    var isVisible: Bool

    init(projection: TransItemProjection) {
        self.transName = projection.transName
        self.displayKmPerGas = projection.displayKmPerGas
        self.displayMeterValue = projection.displayMeterValue
        self.isVisible = projection.isVisible
    }
}

extension TransDraft {

    func toDomain(id: TransID, now: Date = Date()) -> TransDomain {
        TransDomain(
            id: id,
            transName: transName,
            kmPerGas: parseKmPerGas(),
            meterValue: parseMeterValue(),
            isVisible: isVisible,
            isDeleted: false,
            updatedAt: now
        )
    }

    private func parseKmPerGas() -> Int? {
        guard let value = Double(displayKmPerGas) else { return nil }
        return Int(value * 10)
    }

    private func parseMeterValue() -> Int? {
        let raw = displayMeterValue.replacingOccurrences(of: ",", with: "")
        return Int(raw)
    }
}
