import Foundation

struct MarkLinkProjectionAdapter {
    // MARK: - Public
    
    func adaptList(
        markLinks: [MarkLinkDomain]
    ) -> [MarkLinkItemProjection] {
        markLinks
            .filter { !$0.isDeleted }
            .sorted { $0.markLinkSeq < $1.markLinkSeq }
            .map { adapt($0) }
    }

    func adapt(
        _ domain: MarkLinkDomain
    ) -> MarkLinkItemProjection {

        MarkLinkItemProjection(
            id: domain.id,
            markLinkSeq: domain.markLinkSeq,
            markLinkType: domain.markLinkType,
            displayDate: formatDate(domain.markLinkDate),
            markLinkName: domain.markLinkName ?? "",
            members: formatMembers(domain.members),
            displayMeterValue: formatMeter(
                type: domain.markLinkType,
                value: domain.meterValue
            ),
            displayDistanceValue: formatDistance(
                type: domain.markLinkType,
                value: domain.distanceValue
            ),
            actions: formatActions(domain.actions),
            isFuel: domain.isFuel,
            pricePerGas: formatPricePerGas(
                isFuel: domain.isFuel,
                value: domain.pricePerGas
            ),
            gasQuantity: formatGasQuantity(
                isFuel: domain.isFuel,
                value: domain.gasQuantity
            ),
            gasPrice: formatGasPrice(
                isFuel: domain.isFuel,
                value: domain.gasPrice
            ),
            memo: domain.memo
        )
    }
    
    // MARK: - Private formatting

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()
    
    private func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    private func formatMembers(
        _ members: [MemberDomain]
    ) -> [MemberItemProjection] {
        let memberAdapter = MemberProjectionAdapter()
        return members
            .filter { !$0.isDeleted && $0.isVisible }
            .map { memberAdapter.adapt($0) }
    }
    
    private func formatMeter(
        type: MarkOrLink,
        value: Int?
    ) -> String? {
        guard type == .mark,
              let value
        else { return nil }
        return "\(value)"
    }

    private func formatDistance(
        type: MarkOrLink,
        value: Int?
    ) -> String? {
        guard type == .link,
              let value
        else { return nil }
        return "\(value)"
    }

    private func formatActions(
        _ actions: [ActionDomain]
    ) -> [ActionItemProjection] {
        let actionAdapter = ActionProjectionAdapter()
        return actions
            .filter { !$0.isDeleted && $0.isVisible }
            .map { actionAdapter.adapt($0) }
    }

    private func formatPricePerGas(
        isFuel: Bool,
        value: Int?
    ) -> Int? {
        guard isFuel,
              let value
        else { return nil }
        return value
    }

    private func formatGasQuantity(
        isFuel: Bool,
        value: Int?
    ) -> Double? {
        guard isFuel,
              let value
        else { return nil }
        return Double(value) / 10.0
    }

    private func formatGasPrice(
        isFuel: Bool,
        value: Int?
    ) -> Int? {
        guard isFuel else { return nil }
        return value
    }
}
