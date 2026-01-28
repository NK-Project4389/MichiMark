import Foundation

struct TagProjectionAdapter {
    // Domain → Projection（一覧）
    func adaptList(
        tags: [TagDomain]
    ) -> [TagItemProjection] {
        tags
            .filter { !$0.isDeleted }
            .map { adapt($0) }
    }
    
    // Domain → Projection（詳細）
    func adapt(_ domain: TagDomain) -> TagItemProjection {
        TagItemProjection(
            id: domain.id,
            tagName: domain.tagName,
            isVisible: domain.isVisible
        )
    }
}
