enum MarkLinkAdapter {

    static func toDomain(_ core: MarkLinkCore) -> MarkLinkDomain {

        // Mark / Link 排他制御
        let meterValue = core.markLinkType == .mark ? core.meterValue : nil
        let distanceValue = core.markLinkType == .link ? core.distanceValue : nil

        return MarkLinkDomain(
            id: core.id,
            markLinkSeq: core.markLinkSeq,
            markLinkType: core.markLinkType,
            markLinkDate: core.markLinkDate,
            markLinkName: core.markLinkName,
            members: core.members.map(MemberAdapter.toDomain),
            meterValue: meterValue,
            distanceValue: distanceValue,
            actions: core.actions.map(ActionAdapter.toDomain),
            memo: core.memo,
            isFuel: core.isFuel,
            pricePerGas: core.isFuel ? core.pricePerGas : nil,
            gasQuantity: core.isFuel ? core.gasQuantity : nil,
            gasPrice: core.isFuel ? core.gasPrice : nil,
            isDeleted: core.isDeleted,
            createdAt: core.createdAt,
            updatedAt: core.updatedAt
        )
    }

    static func toCore(_ domain: MarkLinkDomain, schemaVersion: Int) -> MarkLinkCore {

        // isFuel=false の場合はガソリン系を強制 nil
        let pricePerGas = domain.isFuel ? domain.pricePerGas : nil
        let gasQuantity = domain.isFuel ? domain.gasQuantity : nil
        let gasPrice = domain.isFuel ? domain.gasPrice : nil

        return MarkLinkCore(
            id: domain.id,
            markLinkSeq: domain.markLinkSeq,
            markLinkType: domain.markLinkType,
            markLinkDate: domain.markLinkDate,
            markLinkName: domain.markLinkName,
            members: domain.members.map { MemberAdapter.toCore($0, schemaVersion: schemaVersion) },
            meterValue: domain.markLinkType == .mark ? domain.meterValue : nil,
            distanceValue: domain.markLinkType == .link ? domain.distanceValue : nil,
            actions: domain.actions.map { ActionAdapter.toCore($0, schemaVersion: schemaVersion) },
            memo: domain.memo,
            isFuel: domain.isFuel,
            pricePerGas: pricePerGas,
            gasQuantity: gasQuantity,
            gasPrice: gasPrice,
            isDeleted: domain.isDeleted,
            schemaVersion: schemaVersion,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
}
