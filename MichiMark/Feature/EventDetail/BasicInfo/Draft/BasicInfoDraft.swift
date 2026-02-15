import Foundation

struct BasicInfoDraft: Equatable, Sendable {
    var eventName: String// イベント
    var selectedTransID: TransID?// 交通手段（選択状態）
    var selectedTransName: String?
    var selectedTagIDs: Set<TagID>// タグ（選択状態）
    var selectedMemberIDs: Set<MemberID>//メンバー（複数状態）
    var selectedTagNames: [TagID: String]// タグ・メンバー（表示名）
    var selectedMemberNames: [MemberID: String]
    
    // 燃費・単価（入力状態）
    var kmPerGas: String
    var pricePerGas: String

    // 支払者（選択状態）
    var selectedPayMemberID: MemberID?
    var selectedPayMemberName: String?
}
