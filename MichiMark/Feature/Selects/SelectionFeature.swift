// 「この Feature は UI と選択状態管理のみを責務とする」
import ComposableArchitecture
import SwiftUI

@Reducer
public struct SelectionFeature<ID: Hashable & Sendable> :Sendable{
    @ObservableState
    public struct State: Equatable {
        public var items: IdentifiedArrayOf<Item>
        public var selected: Set<ID>
        public var allowsMultipleSelection: Bool

        public init(
            items: IdentifiedArrayOf<Item>,
            selected: Set<ID>,
            allowsMultipleSelection: Bool
        ) {
            self.items = items
            self.selected = selected
            self.allowsMultipleSelection = allowsMultipleSelection
        }
    }

    public struct Item: Identifiable, Equatable, Sendable {
        public var id: ID
        public var title: String
        public var subtitle: String?

        public init(id: ID, title: String, subtitle: String? = nil) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
        }
    }

    public enum Action: Sendable, Equatable {
        case itemTapped(ID)
        case doneTapped
        case cancelTapped
        case delegate(Delegate)

        public enum Delegate: Sendable, Equatable {
            case selected(Set<ID>)
            case cancelled
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .itemTapped(id):
                if state.allowsMultipleSelection {
                    if state.selected.contains(id) {
                        state.selected.remove(id)
                    } else {
                        state.selected.insert(id)
                    }
                } else {
                    state.selected = [id]
                }
                return .none

            case .doneTapped:
                return .send(.delegate(.selected(state.selected)))

            case .cancelTapped:
                return .send(.delegate(.cancelled))

            case .delegate:
                return .none
            }
        }
    }
}
