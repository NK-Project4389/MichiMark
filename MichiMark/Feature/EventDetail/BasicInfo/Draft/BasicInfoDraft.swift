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

// MARK: - SelectionContext生成（Trans）
// Draft は Navigation を知らないが、「選択結果をどの Action に戻すか」は知っている前提。
// Root / SelectionFeature を参照せず、純粋なデータ（SelectionContext）だけを返す。
extension BasicInfoDraft {
    func makeTransSelectionContext(
        onSelected: @escaping @Sendable (Set<TransID>) -> EventDetailReducer.Action,
        onCancelled: @escaping @Sendable () -> EventDetailReducer.Action
    ) -> SelectionContext<TransID, EventDetailReducer.Action> {
        SelectionContext(
            preselected: selectedTransID.map { [$0] } ?? [],
            allowsMultipleSelection: false,
            onSelected: onSelected,
            onCancelled: onCancelled
        )
    }

    func makeTagSelectionContext(
        onSelected: @escaping @Sendable (Set<TagID>) -> EventDetailReducer.Action,
        onCancelled: @escaping @Sendable () -> EventDetailReducer.Action
    ) -> SelectionContext<TagID, EventDetailReducer.Action> {
        SelectionContext(
            preselected: selectedTagIDs,
            allowsMultipleSelection: true,
            onSelected: onSelected,
            onCancelled: onCancelled
        )
    }

    func makeMemberSelectionContext(
        onSelected: @escaping @Sendable (Set<MemberID>) -> EventDetailReducer.Action,
        onCancelled: @escaping @Sendable () -> EventDetailReducer.Action
    ) -> SelectionContext<MemberID, EventDetailReducer.Action> {
        SelectionContext(
            preselected: selectedMemberIDs,
            allowsMultipleSelection: true,
            onSelected: onSelected,
            onCancelled: onCancelled
        )
    }

    func makePayMemberSelectionContext(
        onSelected: @escaping @Sendable (Set<MemberID>) -> EventDetailReducer.Action,
        onCancelled: @escaping @Sendable () -> EventDetailReducer.Action
    ) -> SelectionContext<MemberID, EventDetailReducer.Action> {
        SelectionContext(
            preselected: selectedPayMemberID.map { [$0] } ?? [],
            allowsMultipleSelection: false,
            onSelected: onSelected,
            onCancelled: onCancelled
        )
    }
}
