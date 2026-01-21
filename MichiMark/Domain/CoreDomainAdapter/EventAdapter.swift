
enum EventAdapter {

    static func toDomain(_ core: EventCore) -> EventDomain {
        EventDomain(
            id: core.id,
            eventName: core.eventName,
            trans: core.trans.map(TransAdapter.toDomain),
            members: core.members?.map(MemberAdapter.toDomain) ?? [],
            tags: core.tags?.map(TagAdapter.toDomain) ?? [],
            kmPerGas: core.kmPerGas,
            pricePerGas: core.pricePerGas,
            payMember: core.payMember.map(MemberAdapter.toDomain),
            markLinks: core.markLinks?.map(MarkLinkAdapter.toDomain) ?? [],
            payments: core.payments?.map(PaymentAdapter.toDomain) ?? [],
            
            isDeleted: core.isDeleted,
            //schemaVersion
            createdAt: core.createdAt,
            updatedAt: core.updatedAt
        )
    }

    static func toCore(_ domain: EventDomain, schemaVersion: Int) -> EventCore {
        EventCore(
            id: domain.id,
            eventName: domain.eventName,
            trans: domain.trans.map {
                TransAdapter.toCore($0, schemaVersion: schemaVersion)
            },
            members: domain.members?.map {
                MemberAdapter.toCore($0, schemaVersion: schemaVersion)
            },
            tags: domain.tags?.map {
                TagAdapter.toCore($0, schemaVersion: schemaVersion)
            },
            kmPerGas: domain.kmPerGas,
            pricePerGas: domain.pricePerGas,
            payMember: domain.payMember.map {
                MemberAdapter.toCore($0, schemaVersion: schemaVersion)
            },
            markLinks: domain.markLinks?.map {
                MarkLinkAdapter.toCore($0, schemaVersion: schemaVersion)
            },
            payments: domain.payments?.map {
                PaymentAdapter.toCore($0, schemaVersion: schemaVersion)
            },
            isDeleted: domain.isDeleted,
            schemaVersion: schemaVersion,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
            
        )
    }
}
