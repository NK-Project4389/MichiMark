import Foundation

struct BasicInfoDraft: Equatable {

    // イベント
    var eventName: String

    // 交通手段（選択状態）
    var selectedTransID: TransID?
    var selectedTransName: String?

    // タグ・メンバー（選択状態）
    var selectedTagIDs: Set<TagID>
    var selectedMemberIDs: Set<MemberID>

    // タグ・メンバー（表示名）
    var selectedTagNames: [TagID: String]
    var selectedMemberNames: [MemberID: String]
    
    // 燃費・単価（入力状態）
    var kmPerGas: String
    var pricePerGas: String

    // 支払者（選択状態）
    var selectedPayMemberID: MemberID?
    var selectedPayMemberName: String?
}
