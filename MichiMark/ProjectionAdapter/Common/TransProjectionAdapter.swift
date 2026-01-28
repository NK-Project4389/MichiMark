import Foundation

struct TransProjectionAdapter {

    // Domain → Projection（一覧）
    func adaptList(
        transes: [TransDomain]
    ) -> [TransItemProjection] {
        transes
            .filter { !$0.isDeleted }
            .map { adapt($0) }
    }

    // Domain → Projection（詳細）
    func adapt(_ domain: TransDomain) -> TransItemProjection {
        TransItemProjection(
            id: domain.id,
            transName: domain.transName,
            displayKmPerGas: domain.kmPerGas.map {
                String(Double($0) / 10.0)
            } ?? "",
            displayMeterValue: domain.meterValue.map {
                String($0)
            } ?? "",
            isVisible: domain.isVisible
        )
    }
}
