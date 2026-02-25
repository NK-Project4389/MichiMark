import ComposableArchitecture
import Foundation

@Reducer
struct ActionSettingDetailReducer {

    @ObservableState
    struct State {
        let actionID: ActionID
        var projection: ActionItemProjection
        var draft: ActionDraft
        
        var validationError: ValidationError?
        
        var isSaving: Bool = false
        @Presents var alert: AlertState<Action>?
        
        init(projection: ActionItemProjection){
            self.actionID = projection.id
            self.projection = projection
            self.draft = ActionDraft(projection: projection)
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case saveTapped
        case backTapped
        
        case savingFinished
        case saveFailed(String)
        case alert(PresentationAction<Action>)
        case clearAlert
        
        case delegate(Delegate)
        enum Delegate {
            case dismiss
            case saveRequested(ActionID, ActionDraft)
            case didSave(ActionID)
        }
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.draft.actionName):
                let text = state.draft.actionName

                // ★ Validation 判定
                if text.trimmingCharacters(in: .whitespaces).isEmpty {
                    state.validationError = .empty
                } else {
                    state.validationError = nil
                }
                
                return .send(.clearAlert)
                
            case .binding(\.draft.isHidden):
                return .send(.clearAlert)

            case .binding:
                return .none

            case .saveTapped:
                state.alert = nil

                guard state.validationError == nil else {
                    state.alert = AlertState {
                        TextState("入力エラー")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("OK")
                        }
                    } message: {
                        TextState("行動名を入力してください")
                    }
                    return .none
                }

                state.isSaving = true
                return .send(
                    .delegate(.saveRequested(state.actionID, state.draft))
                )
            
            case .savingFinished:
                state.isSaving = false
                return .send(.delegate(.didSave(state.actionID)))

            case let .saveFailed(message):
                state.isSaving = false
                state.alert = AlertState {
                    TextState("保存エラー")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("OK")
                    }
                } message: {
                    TextState(message)
                }
                return .none

            case .clearAlert:
                state.alert = nil
                return .none
                
            case .backTapped, .delegate, .alert:
                return .none
            
            }
        }
    }
}
