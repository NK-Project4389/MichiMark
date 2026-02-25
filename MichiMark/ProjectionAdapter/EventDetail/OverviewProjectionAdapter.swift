struct OverviewProjectionAdapter {

    func adapt(event: EventDomain) -> OverviewProjection {

        let totalDistance = event.markLinks?
            .filter { !$0.isDeleted }
            .compactMap { $0.distanceValue }
            .reduce(0, +)

        let totalGasCost = event.markLinks?
            .filter { !$0.isDeleted && $0.isFuel }
            .compactMap { $0.gasPrice }
            .reduce(0, +)

        return OverviewProjection(
            displayTotalDistance: "\(String(describing: totalDistance)) km",
            displayTotalGasCost: "\(String(describing: totalGasCost)) 円"
        )
    }
}
