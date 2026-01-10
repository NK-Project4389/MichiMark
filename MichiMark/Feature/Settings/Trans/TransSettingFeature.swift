import ComposableArchitecture
import Foundation

@Reducer
struct TransSettingReducer {

    @ObservableState
    struct State: Equatable {
        var transes: IdentifiedArrayOf<TransItemProjection> = []
    }

    enum Action {
        case transSelected(TransID)
        case addTransTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}

