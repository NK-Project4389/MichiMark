import ComposableArchitecture
import Foundation

@Reducer
struct ActionSettingReducer {

    @ObservableState
    struct State: Equatable {
        var actions: IdentifiedArrayOf<ActionInfo> = []
    }

    enum Action {
        case actionSelected(ActionInfo.ID)
        case addActionTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}

