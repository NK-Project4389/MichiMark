import Foundation

struct MemberProjectionAdapter {

    // Domain → Projection（一覧）
    func adaptList(
        members: [MemberDomain]
    ) -> [MemberItemProjection] {
        members
            .filter { !$0.isDeleted }
            .map { adapt($0) }
    }

    // Domain → Projection（詳細）
    func adapt(_ domain: MemberDomain) -> MemberItemProjection {
        MemberItemProjection(
            id: domain.id,
            memberName: domain.memberName,
            mailAddress: domain.mailAddress ?? "",
            isVisible: domain.isVisible
        )
    }
}
