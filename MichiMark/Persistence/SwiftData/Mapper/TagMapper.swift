import SwiftData
import Foundation

protocol TagMapper {
    func toModel(_ domain: TagCore, context: ModelContext) -> TagModel
    func toDomain(_ model: TagModel) -> TagCore
}

final class DefaultTagMapper: TagMapper {

    func toModel(
        _ domain: TagCore,
        context: ModelContext
    ) -> TagModel {

        let tagUUID: UUID = domain.id   // ← ここが重要

        let descriptor = FetchDescriptor<TagModel>(
            predicate: #Predicate { $0.id == tagUUID }
        )
        let existing = try? context.fetch(descriptor).first

        let model: TagModel
        if let existing {
            model = existing
        } else {
            model = TagModel(
                id: domain.id,
                tagName: domain.tagName,
                schemaVersion: domain.schemaVersion,
                createdAt: domain.createdAt
            )
            context.insert(model)
        }

        model.tagName = domain.tagName
        model.isVisible = domain.isVisible
        model.isDeleted = domain.isDeleted
        model.schemaVersion = domain.schemaVersion
        model.updatedAt = .now

        return model
    }

    func toDomain(_ model: TagModel) -> TagCore {
        TagCore(
            id: model.id,
            tagName: model.tagName,
            isVisible: model.isVisible,
            isDeleted: model.isDeleted,
            schemaVersion: model.schemaVersion,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }
}
