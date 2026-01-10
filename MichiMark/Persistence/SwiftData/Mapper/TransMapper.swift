import SwiftData
import Foundation

protocol TransMapper {
    func toModel(_ domain: TransCore, context: ModelContext) -> TransModel
    func toDomain(_ model: TransModel) -> TransCore
}

final class DefaultTransMapper: TransMapper {

    func toModel(
        _ domain: TransCore,
        context: ModelContext
    ) -> TransModel {

        let transUUID: UUID = domain.id   // ← ここが重要

        let descriptor = FetchDescriptor<TransModel>(
            predicate: #Predicate { $0.id == transUUID }
        )
        
        let existing = try? context.fetch(descriptor).first

        let model: TransModel
        if let existing {
            model = existing
        } else {
            model = TransModel(
                id: domain.id,
                transName: domain.transName,
                schemaVersion: domain.schemaVersion,
                createdAt: domain.createdAt
            )
            context.insert(model)
        }

        model.transName = domain.transName
        model.kmPerGas = domain.kmPerGas        // 10倍値そのまま
        model.meterValue = domain.meterValue
        model.isVisible = domain.isVisible
        model.isDeleted = domain.isDeleted
        model.schemaVersion = domain.schemaVersion
        model.updatedAt = .now

        return model
    }

    func toDomain(_ model: TransModel) -> TransCore {
        TransCore(
            id: model.id,
            transName: model.transName,
            kmPerGas: model.kmPerGas,
            meterValue: model.meterValue,
            isVisible: model.isVisible,
            isDeleted: model.isDeleted,
            schemaVersion: model.schemaVersion,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }
}
