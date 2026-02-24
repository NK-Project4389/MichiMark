import ComposableArchitecture
import SwiftUI

@Reducer
struct AddSheetReducer {
    @ObservableState
    struct State: Equatable {
        init() {}
    }

    enum Action: Equatable {
        case delegate(Delegate)

        enum Delegate: Equatable {
            case selected(MarkOrLink)
            case dismiss
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .delegate:
                return .none
            }
        }
    }
}

struct AddSheetView: View {
    let store: StoreOf<AddSheetReducer>

    var body: some View {
        VStack(spacing: 16) {
            Button("地点") {
                store.send(.delegate(.selected(.mark)))
            }
            .font(.headline)

            Button("区間") {
                store.send(.delegate(.selected(.link)))
            }
            .font(.headline)

            Button("キャンセル") {
                store.send(.delegate(.dismiss))
            }
            .foregroundColor(.secondary)
        }
        .padding()
    }
}
