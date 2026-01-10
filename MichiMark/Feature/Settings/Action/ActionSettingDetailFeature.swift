import ComposableArchitecture
import Foundation

@Reducer
struct ActionSettingDetailReducer {

    @ObservableState
    struct State: Equatable {
        let actionID: ActionID
        var projection: ActionItemProjection
        var draft: ActionDraft
        
        init(projection: ActionItemProjection){
            self.actionID = ActionID()
            self.projection = projection
            self.draft = ActionDraft(projection: projection)
        }
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
                state.draft.actionName = text
                return .none
                
            case .visibleToggled:
                state.draft.isVisible.toggle()
                return .none

            case .saveTapped, .backTapped:
                return .none
            }
        }
    }
}
