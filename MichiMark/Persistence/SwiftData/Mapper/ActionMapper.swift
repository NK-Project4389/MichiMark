import SwiftData
import Foundation

protocol ActionMapper {
    func toModel(_ domain: ActionCore, context: ModelContext) -> ActionModel
    func toDomain(_ model: ActionModel) -> ActionCore
}

final class DefaultActionMapper: ActionMapper {

    func toModel(
        _ domain: ActionCore,
        context: ModelContext
    ) -> ActionModel {
        let actionUUID: UUID = domain.id   // ← ここが重要

        let descriptor = FetchDescriptor<ActionModel>(
            predicate: #Predicate { $0.id == actionUUID }
        )
        
        let existing = try? context.fetch(descriptor).first

        let model: ActionModel
        if let existing {
            model = existing
        } else {
            model = ActionModel(
                id: domain.id,
                actionName: domain.actionName,
                schemaVersion: domain.schemaVersion,
                createdAt: domain.createdAt
            )
            context.insert(model)
        }

        model.actionName = domain.actionName
        model.isVisible = domain.isVisible
        model.isDeleted = domain.isDeleted
        model.schemaVersion = domain.schemaVersion
        model.updatedAt = .now

        return model
    }

    func toDomain(_ model: ActionModel) -> ActionCore {
        ActionCore(
            id: model.id,
            actionName: model.actionName,
            isVisible: model.isVisible,
            isDeleted: model.isDeleted,
            schemaVersion: model.schemaVersion,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }
}
