import Foundation

struct BasicInfoProjectionAdapter {

    public init() {}

    func adapt(
        event: EventDomain,
        members: [MemberDomain],
        tags: [TagDomain],
        trans: [TransDomain]
    ) -> BasicInfoProjection {

        let transProjection = trans
            .first(where: { $0.id == event.trans.id })
            .map { TransItemProjection(domain: $0) }

        let memberProjections = members
            .filter { !$0.isDeleted && $0.isVisible }
            .map { MemberItemProjection(domain: $0) }

        let tagProjections = tags
            .filter { !$0.isDeleted && $0.isVisible }
            .map { TagItemProjection(domain: $0) }

        let paymentMemberProjection = event.payMember
            .map { MemberItemProjection(domain: $0) }

        return BasicInfoProjection(
            id: event.id,
            eventName: event.eventName,
            trans: transProjection,
            tags: tagProjections,
            members: memberProjections,
            kmPerGas: event.kmPerGas,
            displayKmPerGas: formatKmPerGas(event.kmPerGas),
            pricePerGas: event.pricePerGas,
            displayPricePerGas: formatPricePerGas(event.pricePerGas),
            payMember: paymentMemberProjection
        )
    }

    // MARK: - Private formatting

    private func formatKmPerGas(_ value: Int?) -> String {
        guard let value else { return "未設定" }
        return String(format: "%.1f km/L", value)
    }

    private func formatPricePerGas(_ value: Int?) -> String {
        guard let value else { return "未設定" }
        return "\(value) 円/L"
    }
}
