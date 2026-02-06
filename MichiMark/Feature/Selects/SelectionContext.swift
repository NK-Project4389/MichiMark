import Foundation

// 「Navigation と Delegate を橋渡しする純粋データ」
// SelectionFeature / Draft / Root のどれでもない純粋なデータ構造
public struct SelectionContext<ID: Hashable & Sendable, RootAction>: Sendable {
    public let preselected: Set<ID>
    public let allowsMultipleSelection: Bool
    public let onSelected: @Sendable (Set<ID>) -> RootAction
    public let onCancelled: @Sendable () -> RootAction

    public init(
        preselected: Set<ID>,
        allowsMultipleSelection: Bool,
        onSelected: @escaping @Sendable (Set<ID>) -> RootAction,
        onCancelled: @escaping @Sendable () -> RootAction
    ) {
        self.preselected = preselected
        self.allowsMultipleSelection = allowsMultipleSelection
        self.onSelected = onSelected
        self.onCancelled = onCancelled
    }
}
