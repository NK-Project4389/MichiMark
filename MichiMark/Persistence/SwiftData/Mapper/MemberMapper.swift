import SwiftData
import Foundation

protocol MemberMapper {
    func toModel(_ domain: MemberCore, context: ModelContext) -> MemberModel
    func toDomain(_ model: MemberModel) -> MemberCore
}

final class DefaultMemberMapper: MemberMapper {

    func toModel(
        _ domain: MemberCore,
        context: ModelContext
    ) -> MemberModel {
        let memberUUID: UUID = domain.id   // ← ここが重要

        let descriptor = FetchDescriptor<MemberModel>(
            predicate: #Predicate { $0.id == memberUUID }
        )
        let existing = try? context.fetch(descriptor).first

        let model: MemberModel
        if let existing {
            model = existing
        } else {
            model = MemberModel(
                id: domain.id,
                memberName: domain.memberName,
                schemaVersion: domain.schemaVersion,
                createdAt: domain.createdAt
            )
            context.insert(model)
        }

        model.memberName = domain.memberName
        model.mailAddress = domain.mailAddress
        model.isVisible = domain.isVisible
        model.isDeleted = domain.isDeleted
        model.schemaVersion = domain.schemaVersion
        model.updatedAt = .now

        return model
    }

    func toDomain(_ model: MemberModel) -> MemberCore {
        MemberCore(
            id: model.id,
            memberName: model.memberName,
            mailAddress: model.mailAddress,
            isVisible: model.isVisible,
            isDeleted: model.isDeleted,
            schemaVersion: model.schemaVersion,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }
}
