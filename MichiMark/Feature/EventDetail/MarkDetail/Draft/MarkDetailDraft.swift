import Foundation

struct MarkDetailDraft: Equatable {
    var markLinkSeq: Int
    var markLinkType: MarkOrLink
    var displayDate: String
    var markLinkName: String
    var selectedMemberIDs: Set<MemberID>
    var selectedMemberNames: [MemberID: String]
    var displayMeterValue: String//メーター
    var displayDistanceValue: String//走行距離
    var selectedActionIDs: Set<ActionID>//行動
    var selectedActionNames: [ActionID: String]//(表示名）
    var isFuel: Bool
    var fuelDetail: FuelDetailReducer.State?
    var memo: String
}

extension MarkDetailDraft {

    init(projection: MarkLinkItemProjection) {
        self.markLinkSeq = projection.markLinkSeq
        self.markLinkType = projection.markLinkType
        self.displayDate = projection.displayDate
        self.markLinkName = projection.markLinkName

        self.selectedMemberIDs = Set(
            projection.members.map(\.id)
        )

        self.selectedMemberNames = Dictionary(
            uniqueKeysWithValues:
                projection.members.map { ($0.id, $0.memberName) }
        )

        self.displayMeterValue = projection.displayMeterValue ?? ""
        self.displayDistanceValue = projection.displayDistanceValue ?? ""

        self.selectedActionIDs = Set(
            projection.actions.map(\.id)
        )

        self.selectedActionNames = Dictionary(
            uniqueKeysWithValues:
                projection.actions.map { ($0.id, $0.actionName) }
        )
        
        self.isFuel = projection.isFuel
        if projection.isFuel {
            self.fuelDetail = FuelDetailReducer.State(
                pricePerGas: projection.pricePerGas.map(String.init) ?? "",
                gasQuantity: projection.gasQuantity.map { String(Double($0) / 10.0) } ?? "",
                gasPrice: projection.gasPrice.map(String.init) ?? ""
            )

        } else {
            self.fuelDetail = nil
        }


        self.memo = projection.memo ?? ""
    }
}
