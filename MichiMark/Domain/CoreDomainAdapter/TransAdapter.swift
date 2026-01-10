enum TransAdapter {

    static func toDomain(_ core: TransCore) -> TransDomain {
        TransDomain(
            id: core.id,
            transName: core.transName,
            kmPerGas: core.kmPerGas,
            meterValue: core.meterValue,
            isVisible: core.isVisible,
            isDeleted: core.isDeleted,
            createdAt: core.createdAt,
            updatedAt: core.updatedAt
        )
    }

    static func toCore(_ domain: TransDomain, schemaVersion: Int) -> TransCore {
        TransCore(
            id: domain.id,
            transName: domain.transName,
            kmPerGas: domain.kmPerGas,
            meterValue: domain.meterValue,
            isVisible: domain.isVisible,
            isDeleted: domain.isDeleted,
            schemaVersion: schemaVersion,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
}
