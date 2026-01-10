import SwiftData
import Foundation

protocol PaymentMapper {
    func toModel(_ domain: PaymentCore, context: ModelContext) -> PaymentModel
    func toDomain(_ model: PaymentModel) -> PaymentCore
}

final class DefaultPaymentMapper: PaymentMapper {

    private let memberMapper: MemberMapper

    init(memberMapper: MemberMapper) {
        self.memberMapper = memberMapper
    }

    func toModel(
        _ domain: PaymentCore,
        context: ModelContext
    ) -> PaymentModel {

        let paymentUUID: UUID = domain.id   // ← ここが重要

        let descriptor = FetchDescriptor<PaymentModel>(
            predicate: #Predicate { $0.id == paymentUUID }
        )
        let existing = try? context.fetch(descriptor).first

        let model: PaymentModel
        if let existing {
            model = existing
        } else {
            model = PaymentModel(
                id: domain.id,
                sortOrder: domain.paymentSeq,
                paymentAmount: domain.paymentAmount,
                schemaVersion: domain.schemaVersion,
                createdAt: domain.createdAt
            )
            context.insert(model)
        }

        model.sortOrder = domain.paymentSeq
        model.paymentAmount = domain.paymentAmount
        model.paymentMember = domain.paymentMember
            .map { memberMapper.toModel($0, context: context) }
        model.splitMembers = domain.splitMembers
            .map { memberMapper.toModel($0, context: context) }

        model.memo = domain.paymentMemo
        model.isDeleted = domain.isDeleted
        model.schemaVersion = domain.schemaVersion
        model.updatedAt = .now

        return model
    }

    func toDomain(_ model: PaymentModel) -> PaymentCore {
        PaymentCore(
            id: model.id,
            paymentSeq: model.sortOrder,
            paymentAmount: model.paymentAmount,
            paymentMember: model.paymentMember
                .map { memberMapper.toDomain($0) },
            splitMembers: model.splitMembers
                .map { memberMapper.toDomain($0) },
            paymentMemo: model.memo,
            isDeleted: model.isDeleted,
            schemaVersion: model.schemaVersion,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }
}
