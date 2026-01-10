import SwiftData
import Foundation

protocol MarkLinkMapper {
    func toModel(
        _ domain: MarkLinkCore,
        context: ModelContext
    ) -> MarkLinkModel

    func toDomain(
        _ model: MarkLinkModel
    ) -> MarkLinkCore
}

final class DefaultMarkLinkMapper: MarkLinkMapper {

    // MARK: - Dependencies
    private let actionMapper: ActionMapper

    init(actionMapper: ActionMapper) {
        self.actionMapper = actionMapper
    }

    // MARK: - Domain → Model
    func toModel(
        _ domain: MarkLinkCore,
        context: ModelContext
    ) -> MarkLinkModel {

        // 既存 Model を検索
        let markLinkUUID: UUID = domain.id   // ← ここが重要

        let descriptor = FetchDescriptor<MarkLinkModel>(
            predicate: #Predicate { $0.id == markLinkUUID }
        )
        
        let existingModel = try? context.fetch(descriptor).first

        let model: MarkLinkModel
        if let existingModel {
            model = existingModel
        } else {
            model = MarkLinkModel(
                id: domain.id,
                sortOrder: domain.markLinkSeq,
                typeRawValue: rawValue(from: domain.markLinkType),
                date: domain.markLinkDate,
                isFuel: domain.isFuel,
                schemaVersion: domain.schemaVersion,
                createdAt: domain.createdAt
            )
            context.insert(model)
        }

        // ---- 基本項目（そのまま）----
        model.sortOrder = domain.markLinkSeq
        model.typeRawValue = rawValue(from: domain.markLinkType)
        model.date = domain.markLinkDate
        model.name = domain.markLinkName
        model.meterValue = domain.meterValue
        model.distanceValue = domain.distanceValue
        model.memo = domain.memo

        // ---- Fuel ----
        model.isFuel = domain.isFuel
        model.pricePerGas = domain.pricePerGas
        model.gasQuantity = domain.gasQuantity   // 10倍値保持
        model.gasPrice = domain.gasPrice

        // ---- Action（共有マスタ / nullify）----
        model.actions = domain.actions
            .map { actionMapper.toModel($0, context: context) }

        // ---- System ----
        model.isDeleted = domain.isDeleted
        model.schemaVersion = domain.schemaVersion
        model.updatedAt = .now

        return model
    }

    // MARK: - Model → Domain
    func toDomain(
        _ model: MarkLinkModel
    ) -> MarkLinkCore {

        MarkLinkCore(
            id: model.id,
            markLinkSeq: model.sortOrder,
            markLinkType: markOrLink(from: model.typeRawValue),
            markLinkDate: model.date,
            markLinkName: model.name,
            meterValue: model.meterValue,
            distanceValue: model.distanceValue,
            actions: model.actions.map { actionMapper.toDomain($0) },
            memo: model.memo,
            isFuel: model.isFuel,
            pricePerGas: model.pricePerGas,
            gasQuantity: model.gasQuantity,   // 10倍値そのまま
            gasPrice: model.gasPrice,
            isDeleted: model.isDeleted,
            schemaVersion: model.schemaVersion,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }
    
    // MARK: - RawValue Conversion

    private func rawValue(from type: MarkOrLink) -> String {
        switch type {
        case .mark:
            return "mark"
        case .link:
            return "link"
        }
    }

    private func markOrLink(from rawValue: String) -> MarkOrLink {
        switch rawValue {
        case "mark":
            return .mark
        case "link":
            return .link
        default:
            return .mark
        }
    }
}
