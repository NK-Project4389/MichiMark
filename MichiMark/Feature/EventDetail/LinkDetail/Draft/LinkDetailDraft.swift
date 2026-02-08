import Foundation

struct LinkDetailDraft: Equatable {
    var markLinkSeq: Int
    var markLinkType: MarkOrLink
    var displayDate: String
    var displayDateAsDate: Date
    var markLinkName: String
    var selectedMemberIDs: Set<MemberID>
    var selectedMemberNames: [MemberID: String]
    var displayDistanceValue: String//走行距離
    var selectedActionIDs: Set<ActionID>//行動
    var selectedActionNames: [ActionID: String]//(表示名）
    var isFuel: Bool
    var fuelDetail: FuelDetailReducer.State?
    var memo: String
}

extension LinkDetailDraft {

    init(projection: MarkLinkItemProjection) {
        self.markLinkSeq = projection.markLinkSeq
        self.markLinkType = .link
        self.displayDate = projection.displayDate
        self.displayDateAsDate = Self.parseDisplayDate(projection.displayDate)
        self.markLinkName = projection.markLinkName

        self.selectedMemberIDs = Set(
            projection.members.map(\.id)
        )

        self.selectedMemberNames = Dictionary(
            uniqueKeysWithValues:
                projection.members.map { ($0.id, $0.memberName) }
        )

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

    /// DatePickerなど「Date」を受け取った時に、表示文字列と保持Dateを同期
    mutating func updateDisplayDate(_ date: Date) {
        displayDateAsDate = date
        displayDate = Self.displayDateFormatter.string(from: date)
    }

    /// projectionなど「表示文字列」を受け取った時に Date を復元
    static func parseDisplayDate(_ string: String) -> Date {
        // まず想定フォーマットで解析（例：yyyy/MM/dd）
        if let date = displayDateFormatter.date(from: string) {
            return date
        }
        // だめならISO8601も試す（もしサーバ/永続層がISOを返す可能性があるなら）
        if let iso = ISO8601DateFormatter().date(from: string) {
            return iso
        }
        // 最終フォールバック：今日
        return Date()
    }

    private static let displayDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyy/MM/dd"   // ← projection.displayDateの実フォーマットに合わせて必要なら変更
        return df
    }()

}

extension LinkDetailDraft {
    func toProjection(id: MarkLinkID) -> MarkLinkItemProjection {
        let memberItems = selectedMemberIDs.map { memberID in
            MemberItemProjection(
                id: memberID,
                memberName: selectedMemberNames[memberID] ?? "",
                mailAddress: nil,
                isVisible: true
            )
        }

        let actionItems = selectedActionIDs.map { actionID in
            ActionItemProjection(
                id: actionID,
                actionName: selectedActionNames[actionID] ?? "",
                isVisible: true
            )
        }

        let distanceValue = Self.emptyToNil(displayDistanceValue)

        let fuelPricePerGas = isFuel ? Self.parseInt(fuelDetail?.pricePerGas) : nil
        let fuelGasQuantity = isFuel ? Self.parseDouble(fuelDetail?.gasQuantity) : nil
        let fuelGasPrice = isFuel ? Self.parseInt(fuelDetail?.gasPrice) : nil

        return MarkLinkItemProjection(
            id: id,
            markLinkSeq: markLinkSeq,
            markLinkType: .link,
            displayDate: displayDate,
            markLinkName: markLinkName,
            members: memberItems,
            displayMeterValue: nil,
            displayDistanceValue: distanceValue,
            actions: actionItems,
            isFuel: isFuel,
            pricePerGas: fuelPricePerGas,
            gasQuantity: fuelGasQuantity,
            gasPrice: fuelGasPrice,
            memo: Self.emptyToNil(memo)
        )
    }

    private static func emptyToNil(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func parseInt(_ value: String?) -> Int? {
        guard let value else { return nil }
        let cleaned = value.replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : Int(cleaned)
    }

    private static func parseDouble(_ value: String?) -> Double? {
        guard let value else { return nil }
        let cleaned = value.replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : Double(cleaned)
    }
}
