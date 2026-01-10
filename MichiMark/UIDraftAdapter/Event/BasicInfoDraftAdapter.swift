// BasicInfoDraftAdapter.swift

import Foundation

enum BasicInfoDraftAdapter {

    static func adapt(
        draft: BasicInfoDraft
    ) throws -> EventBasicInfoDraftDomainAdapter {

        //eventName
        guard !draft.eventName.isEmpty else {
            throw DraftValidationError.requiredFieldMissing(field: .eventName)
        }

        //kmPerGas
        let kmPerGas: Double?
        if draft.kmPerGas.isEmpty {
            kmPerGas = nil
        } else if let value = Double(draft.kmPerGas), value > 0 {
            kmPerGas = value
        } else {
            throw DraftValidationError.invalidFormat(field: .kmPerGas)
        }

        //pricePerGas
        let pricePerGas: Int?
        if draft.pricePerGas.isEmpty {
            pricePerGas = nil
        } else if let value = Int(draft.pricePerGas), value > 0 {
            pricePerGas = value
        } else {
            throw DraftValidationError.invalidFormat(field: .pricePerGas)
        }

        return EventBasicInfoDraftDomainAdapter(
            eventName: draft.eventName,
            kmPerGas: kmPerGas,
            pricePerGas: pricePerGas
        )
    }
}

