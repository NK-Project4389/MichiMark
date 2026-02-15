import ComposableArchitecture
import Foundation

@Reducer
struct ActionSettingCreateReducer {

    @ObservableState
    struct State {
        var detail: ActionSettingDetailReducer.State

        init() {
            let newID = ActionID()
            let domain = ActionDomain(id: newID, actionName: "")
            let projection = ActionProjectionAdapter().adapt(domain)
            self.detail = ActionSettingDetailReducer.State(projection: projection)
        }
    }

    enum Action {
        case detail(ActionSettingDetailReducer.Action)
    }

    @Dependency(\.actionRepository) var actionRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .detail(.delegate(.saveRequested(actionID, draft))):
                let domain = ActionDomain(
                    id: actionID,
                    actionName: draft.actionName,
                    isVisible: draft.isVisible,
                    updatedAt: Date()
                )
                return .run { send in
                    do {
                        try await actionRepository.save(domain)
                        await send(.detail(.savingFinished))
                    } catch {
                        await send(
                            .detail(
                                .saveFailed("保存に失敗しました。再度お試しください。")
                            )
                        )
                    }
                }

            default:
                return .none
            }
        }
        Scope(state: \.detail, action: \.detail) {
            ActionSettingDetailReducer()
        }
    }
}
