import Foundation

struct ActionProjectionAdapter {

    // Domain → Projection（一覧）
    func adaptList(
        actions: [ActionDomain]
    ) -> [ActionItemProjection] {
        actions
            .filter { !$0.isDeleted }
            .map { adapt($0) }
    }

    // Domain → Projection（詳細）
    func adapt(_ domain: ActionDomain) -> ActionItemProjection {
        ActionItemProjection(
            id: domain.id,
            actionName: domain.actionName,
            isVisible: domain.isVisible
        )
    }
}
