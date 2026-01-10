import Foundation

public struct EventDetailProjectionAdapter {

    private let basicInfoAdapter: BasicInfoProjectionAdapter
    private let michiInfoAdapter: MichiInfoListProjectionAdapter
    private let paymentInfoAdapter: PaymentInfoProjectionAdapter
    private let overviewAdapter: OverviewProjectionAdapter

    init(
        basicInfoAdapter: BasicInfoProjectionAdapter,
        michiInfoAdapter: MichiInfoListProjectionAdapter,
        paymentInfoAdapter: PaymentInfoProjectionAdapter,
        overviewAdapter: OverviewProjectionAdapter
    ) {
        self.basicInfoAdapter = basicInfoAdapter
        self.michiInfoAdapter = michiInfoAdapter
        self.paymentInfoAdapter = paymentInfoAdapter
        self.overviewAdapter = overviewAdapter
    }

    func adapt(
        event: EventDomain,
        markLinks: [MarkLinkDomain],
        payments: [PaymentDomain],
        members: [MemberDomain],
        actions: [ActionDomain],
        tags: [TagDomain],
        trans: [TransDomain]
    ) -> EventDetailProjection {

        return EventDetailProjection(
            eventId: event.id,
            basicInfo: basicInfoAdapter.adapt(
                event: event,
                members: members,
                tags: tags,
                trans: trans
            ),
            michiInfo: michiInfoAdapter.adapt(
                markLinks: markLinks
            ),
            paymentInfo: paymentInfoAdapter.adapt(
                payments: payments
            ),
            overview: overviewAdapter.adapt(
                event: event
            )
        )
    }
}
