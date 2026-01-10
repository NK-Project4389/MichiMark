import ComposableArchitecture
import Foundation

@Reducer
struct ActionSettingReducer {

    @ObservableState
    struct State: Equatable {
        var actions: IdentifiedArrayOf<ActionItemProjection> = []
    }

    enum Action {
        case actionSelected(ActionID)
        case addActionTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}

