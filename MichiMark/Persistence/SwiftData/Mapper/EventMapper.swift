import SwiftData
import Foundation

protocol EventMapper {
    func toModel(
        _ domain: EventCore,
        context: ModelContext
    ) -> EventModel

    func toDomain(
        _ model: EventModel
    ) -> EventCore
}

final class DefaultEventMapper: EventMapper {

    // MARK: - Dependencies
    private let transMapper: TransMapper
    private let memberMapper: MemberMapper
    private let tagMapper: TagMapper
    private let markLinkMapper: MarkLinkMapper
    private let paymentMapper: PaymentMapper

    init(
        transMapper: TransMapper,
        memberMapper: MemberMapper,
        tagMapper: TagMapper,
        markLinkMapper: MarkLinkMapper,
        paymentMapper: PaymentMapper
    ) {
        self.transMapper = transMapper
        self.memberMapper = memberMapper
        self.tagMapper = tagMapper
        self.markLinkMapper = markLinkMapper
        self.paymentMapper = paymentMapper
    }

    // MARK: - Domain → Model
    func toModel(
        _ domain: EventCore,
        context: ModelContext
    ) -> EventModel {

        // 既存 Model を検索（更新か新規かを判定）
        let eventUUID: UUID = domain.id   // ← ここが重要

        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { $0.id == eventUUID }
        )


        let existingModel = try? context.fetch(descriptor).first

        let model: EventModel
        if let existingModel {
            model = existingModel
        } else {
            model = EventModel(
                id: domain.id,
                eventName: domain.eventName,
                schemaVersion: domain.schemaVersion,
                createdAt: domain.createdAt
            )
            context.insert(model)
        }

        // ---- 基本項目（そのまま）----
        model.eventName = domain.eventName
        model.kmPerGas = domain.kmPerGas          // 10倍値そのまま
        model.pricePerGas = domain.pricePerGas
        model.isDeleted = domain.isDeleted
        model.schemaVersion = domain.schemaVersion

        // ---- 参照 Entity（nullify 前提）----
        model.trans = domain.trans
            .map { transMapper.toModel($0, context: context) }

        model.members = domain.members?
            .map { memberMapper.toModel($0, context: context) } ?? []

        model.tags = domain.tags?
            .map { tagMapper.toModel($0, context: context) } ?? []

        model.payMember = domain.payMember
            .map { memberMapper.toModel($0, context: context) }

        // ---- 従属 Entity（cascade）----
        model.markLinks = domain.markLinks?
            .map { markLinkMapper.toModel($0, context: context) } ?? []

        model.payments = domain.payments?
            .map { paymentMapper.toModel($0, context: context) } ?? []

        // ---- 日時制御 ----
        model.updatedAt = .now

        return model
    }

    // MARK: - Model → Domain
    func toDomain(
        _ model: EventModel
    ) -> EventCore {

        EventCore(
            id: model.id,
            eventName: model.eventName,
            trans: model.trans.map { transMapper.toDomain($0) },
            members: model.members.map { memberMapper.toDomain($0) },
            tags: model.tags.map { tagMapper.toDomain($0) },
            kmPerGas: model.kmPerGas,              // 10倍値そのまま
            pricePerGas: model.pricePerGas,
            payMember: model.payMember.map { memberMapper.toDomain($0) },
            markLinks: model.markLinks
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { markLinkMapper.toDomain($0) },
            payments: model.payments
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { paymentMapper.toDomain($0) },
            isDeleted: model.isDeleted,
            schemaVersion: model.schemaVersion,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }
}
