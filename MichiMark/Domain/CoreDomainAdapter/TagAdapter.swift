enum TagAdapter {

    static func toDomain(_ core: TagCore) -> TagDomain {
        TagDomain(
            id: core.id,
            tagName: core.tagName,
            isVisible: core.isVisible,
            isDeleted: core.isDeleted,
            createdAt: core.createdAt,
            updatedAt: core.updatedAt
        )
    }

    static func toCore(_ domain: TagDomain, schemaVersion: Int) -> TagCore {
        TagCore(
            id: domain.id,
            tagName: domain.tagName,
            isVisible: domain.isVisible,
            isDeleted: domain.isDeleted,
            schemaVersion: schemaVersion,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
}
