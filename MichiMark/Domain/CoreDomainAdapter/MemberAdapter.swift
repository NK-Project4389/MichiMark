enum MemberAdapter {

    static func toDomain(_ core: MemberCore) -> MemberDomain {
        MemberDomain(
            id: core.id,
            memberName: core.memberName,
            mailAddress: core.mailAddress,
            isVisible: core.isVisible,
            isDeleted: core.isDeleted,
            createdAt: core.createdAt,
            updatedAt: core.updatedAt
        )
    }

    static func toCore(_ domain: MemberDomain, schemaVersion: Int) -> MemberCore {
        MemberCore(
            id: domain.id,
            memberName: domain.memberName,
            mailAddress: domain.mailAddress,
            isVisible: domain.isVisible,
            isDeleted: domain.isDeleted,
            schemaVersion: schemaVersion,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
}
