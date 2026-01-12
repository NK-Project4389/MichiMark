import ComposableArchitecture
import Foundation

@Reducer
struct MemberSettingDetailReducer {

    @ObservableState
    struct State {
        let memberID: MemberID
        var projection: MemberItemProjection
        var draft: MemberDraft
        
        var validationError: ValidationError?
        
        var isSaving: Bool = false
        @Presents var alert: AlertState<Action>?
        
        init(projection: MemberItemProjection){
            self.memberID = projection.id
            self.projection = projection
            self.draft = MemberDraft(projection: projection)
        }
    }

    enum Action {
        case memberNameChanged(String)
        case visibleToggled
        
        case saveTapped
        case backTapped
    
        case savingFinished
        case saveFailed(String)
        case alert(PresentationAction<Action>)
        case clearAlert
        
        case delegate(Delegate)
        enum Delegate {
            case dismiss
            case saveRequested(MemberID, MemberDraft)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .memberNameChanged(text):
                state.draft.memberName = text
                
                // ★ Validation 判定
                if text.trimmingCharacters(in: .whitespaces).isEmpty {
                    state.validationError = .empty
                } else {
                    state.validationError = nil
                }
                
                return .send(.clearAlert)

            case .visibleToggled:
                state.draft.isVisible.toggle()
                return .send(.clearAlert)

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
                        TextState("メンバー名を入力してください")
                    }
                    return .none
                }

                state.isSaving = true
                return .send(
                    .delegate(.saveRequested(state.memberID, state.draft))
                )

            case .savingFinished:
                state.isSaving = false
                return .none

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
                
            case .backTapped, .alert, .delegate:
                return .none
            }
        }
    }
}
