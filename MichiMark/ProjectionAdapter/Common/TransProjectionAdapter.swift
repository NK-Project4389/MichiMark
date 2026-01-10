import Foundation

struct TransProjectionAdapter {

    // Domain → Projection（一覧）
    func adaptList(
        transes: [TransDomain]
    ) -> [TransItemProjection] {
        transes
            .filter { !$0.isDeleted }
            .map { TransItemProjection(domain: $0) }
    }

    // Domain → Projection（詳細）
    func adaptItem(_ domain: TransDomain) -> TransItemProjection {
        TransItemProjection(domain: domain)
    }
}
