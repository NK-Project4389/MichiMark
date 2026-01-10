enum EventAdapter {

    static func toDomain(_ core: EventCore) -> EventDomain {

        guard let transCore = core.trans else {
            fatalError("EventCore.trans must not be nil")
        }

        return EventDomain(
            id: core.id,
            eventName: core.eventName,
            trans: TransAdapter.toDomain(transCore),
            members: core.members.map(MemberAdapter.toDomain),
            tags: core.tags.map(TagAdapter.toDomain),
            kmPerGas: core.kmPerGas,
            pricePerGas: core.pricePerGas,
            payMember: core.payMember.map(MemberAdapter.toDomain),
            markLinks: core.markLinks.map(MarkLinkAdapter.toDomain),
            payments: core.payments.map(PaymentAdapter.toDomain),
            isDeleted: core.isDeleted,
            createdAt: core.createdAt,
            updatedAt: core.updatedAt
        )
    }

    static func toCore(_ domain: EventDomain, schemaVersion: Int) -> EventCore {
        EventCore(
            id: domain.id,
            eventName: domain.eventName,
            trans: TransAdapter.toCore(domain.trans, schemaVersion: schemaVersion),
            members: domain.members.map {
                MemberAdapter.toCore($0, schemaVersion: schemaVersion)
            },
            tags: domain.tags.map {
                TagAdapter.toCore($0, schemaVersion: schemaVersion)
            },
            kmPerGas: domain.kmPerGas,
            pricePerGas: domain.pricePerGas,
            payMember: domain.payMember.map {
                MemberAdapter.toCore($0, schemaVersion: schemaVersion)
            },
            markLinks: domain.markLinks.map {
                MarkLinkAdapter.toCore($0, schemaVersion: schemaVersion)
            },
            payments: domain.payments.map {
                PaymentAdapter.toCore($0, schemaVersion: schemaVersion)
            },
            isDeleted: domain.isDeleted,
            schemaVersion: schemaVersion,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
}
