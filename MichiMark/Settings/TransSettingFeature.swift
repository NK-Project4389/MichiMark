import ComposableArchitecture
import Foundation

@Reducer
struct TransSettingReducer {

    @ObservableState
    struct State: Equatable {
        var transes: IdentifiedArrayOf<TransInfo> = []
    }

    enum Action {
        case transSelected(TransInfo.ID)
        case addTransTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}

