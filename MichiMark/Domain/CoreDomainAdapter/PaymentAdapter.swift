enum PaymentAdapter {

    static func toDomain(_ core: PaymentCore) -> PaymentDomain {
        guard let paymentMember = core.paymentMember else {
            fatalError("PaymentCore.paymentMember must not be nil")
        }

        return PaymentDomain(
            id: core.id,
            paymentSeq: core.paymentSeq,
            paymentAmount: core.paymentAmount,
            paymentMember: MemberAdapter.toDomain(paymentMember),
            splitMembers: core.splitMembers.map(MemberAdapter.toDomain),
            paymentMemo: core.paymentMemo,
            isDeleted: core.isDeleted,
            createdAt: core.createdAt,
            updatedAt: core.updatedAt
        )
    }

    static func toCore(_ domain: PaymentDomain, schemaVersion: Int) -> PaymentCore {
        PaymentCore(
            id: domain.id,
            paymentSeq: domain.paymentSeq,
            paymentAmount: domain.paymentAmount,
            paymentMember: MemberAdapter.toCore(domain.paymentMember, schemaVersion: schemaVersion),
            splitMembers: domain.splitMembers.map {
                MemberAdapter.toCore($0, schemaVersion: schemaVersion)
            },
            paymentMemo: domain.paymentMemo,
            isDeleted: domain.isDeleted,
            schemaVersion: schemaVersion,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
}
