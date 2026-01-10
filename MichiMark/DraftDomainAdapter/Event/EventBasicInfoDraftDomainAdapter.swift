// EventBasicInfo.swift

import Foundation

struct EventBasicInfoDraftDomainAdapter: Equatable {

    /// イベント名（必須想定）
    let eventName: String

    /// 燃費（km/L）
    let kmPerGas: Double?

    /// ガソリン単価（円/L）
    let pricePerGas: Int?

    init(
        eventName: String,
        kmPerGas: Double?,
        pricePerGas: Int?
    ) {
        self.eventName = eventName
        self.kmPerGas = kmPerGas
        self.pricePerGas = pricePerGas
    }
}
