import Foundation

struct ActionProjectionAdapter {

    // Domain → Projection（一覧）
    func adaptList(
        actions: [ActionDomain]
    ) -> [ActionItemProjection] {
        actions
            .filter { !$0.isDeleted }
            .map { ActionItemProjection(domain: $0) }
    }

    // Domain → Projection（詳細）
    func adaptItem(_ domain: ActionDomain) -> ActionItemProjection {
        ActionItemProjection(domain: domain)
    }
}
