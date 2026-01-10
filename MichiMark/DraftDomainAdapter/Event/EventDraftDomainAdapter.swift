// Event.swift

import Foundation

struct EventDraftDomainAdapter: Equatable {

    let id: EventID
    let basicInfo: EventBasicInfoDraftDomainAdapter

    // 将来拡張
    // let michiInfo: EventMichiInfo?
    // let paymentInfo: EventPaymentInfo?

    init(
        id: EventID,
        basicInfo: EventBasicInfoDraftDomainAdapter,
//        michiInfo: EventMichiInfo? = nil,
//        paymentInfo: EventPaymentInfo? = nil
    ) {
        self.id = id
        self.basicInfo = basicInfo
//        self.michiInfo = michiInfo
//        self.paymentInfo = paymentInfo
    }
}
