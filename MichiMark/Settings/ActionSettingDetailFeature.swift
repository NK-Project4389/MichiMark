import ComposableArchitecture
import Foundation

@Reducer
struct ActionSettingDetailReducer {

    @ObservableState
    struct State: Equatable {
        let actionID: ActionID
        var actionName: String = ""
        var isVisible: Bool = true
    }

    enum Action {
        case actionNameChanged(String)

        case visibleToggled
        case saveTapped
        case backTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .actionNameChanged(text):
                state.actionName = text
                return .none

            case .visibleToggled:
                state.isVisible.toggle()
                return .none

            case .saveTapped, .backTapped:
                return .none
            }
        }
    }
}
