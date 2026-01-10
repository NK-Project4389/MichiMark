import Foundation

enum ActionAdapter {

    static func toDomain(_ core: ActionCore) -> ActionDomain {
        ActionDomain(
            id: core.id,
            actionName: core.actionName,
            isVisible: core.isVisible,
            isDeleted: core.isDeleted,
            createdAt: core.createdAt,
            updatedAt: core.updatedAt
        )
    }

    static func toCore(_ domain: ActionDomain, schemaVersion: Int) -> ActionCore {
        ActionCore(
            id: domain.id,
            actionName: domain.actionName,
            isVisible: domain.isVisible,
            isDeleted: domain.isDeleted,
            schemaVersion: schemaVersion,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
}
