import Foundation

struct MemberProjectionAdapter {

    // Domain → Projection（一覧）
    func adaptList(
        members: [MemberDomain]
    ) -> [MemberItemProjection] {
        members
            .filter { !$0.isDeleted }
            .map { MemberItemProjection(domain: $0) }
    }

    // Domain → Projection（詳細）
    func adaptItem(_ domain: MemberDomain) -> MemberItemProjection {
        MemberItemProjection(domain: domain)
    }
}
