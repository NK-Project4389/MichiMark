import Foundation

public struct EventDetailProjectionAdapter {

    private let basicInfoAdapter: BasicInfoProjectionAdapter
    private let markLinkAdapter: MarkLinkProjectionAdapter
    private let paymentInfoAdapter: PaymentInfoProjectionAdapter
    private let overviewAdapter: OverviewProjectionAdapter

    init(
        basicInfoAdapter: BasicInfoProjectionAdapter,
        markLinkAdapter: MarkLinkProjectionAdapter,
        paymentInfoAdapter: PaymentInfoProjectionAdapter,
        overviewAdapter: OverviewProjectionAdapter
    ) {
        self.basicInfoAdapter = basicInfoAdapter
        self.markLinkAdapter = markLinkAdapter
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
        trans: TransDomain
    ) -> EventDetailProjection {

        return EventDetailProjection(
            eventId: event.id,
            basicInfo: basicInfoAdapter.adapt(
                event: event,
                members: members,
                tags: tags,
                trans: trans
            ),
            michiInfo: MichiInfoListProjection(
                items: markLinkAdapter.adaptList(markLinks: markLinks)
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
