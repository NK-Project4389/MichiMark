import Foundation

struct TagProjectionAdapter {

    // Domain → Projection（一覧）
    func adaptList(
        tags: [TagDomain]
    ) -> [TagItemProjection] {
        tags
            .filter { !$0.isDeleted }
            .map { TagItemProjection(domain: $0) }
    }

    // Domain → Projection（詳細）
    func adaptItem(_ domain: TagDomain) -> TagItemProjection {
        TagItemProjection(domain: domain)
    }
}
