import ComposableArchitecture
import Foundation

@Reducer
struct ActionSettingReducer {

    @ObservableState
    struct State {
        var actions: IdentifiedArrayOf<ActionItemProjection> = []
        
        @Presents var detail: ActionSettingDetailReducer.State?
    }

    enum Action {
        case onAppear
        case actionsLoaded([ActionDomain])
        
        case actionSelected(ActionID)
        case addActionTapped
        
        case detail(PresentationAction<ActionSettingDetailReducer.Action>)
    }
    
    @Dependency(\.actionRepository) var actionRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            let actionAdapter = ActionProjectionAdapter()
            
            switch action{
            case .onAppear:
                return .run { send in
                                let actions = try await actionRepository.fetchAll()
                                await send(.actionsLoaded(actions))
                            }
                
            case let .actionsLoaded(domains):
                state.actions = IdentifiedArray(
                    uniqueElements: domains.map{ actionAdapter.adapt($0) }
                            )
                return .none
                
            case let .actionSelected(actionID):
                guard let projection = state.actions[id: actionID] else {
                    return .none
                }
                state.detail = ActionSettingDetailReducer.State(projection: projection)
                return .none

            case .addActionTapped:
                let domain = ActionDomain(id: UUID(), actionName: "")
                let projection = actionAdapter.adapt(domain)
                state.detail = ActionSettingDetailReducer.State(projection: projection)
                return .none
                
            case let .detail(.presented(.delegate(.saveRequested(actionID, draft)))):
                let isNew = state.actions[id: actionID] == nil
                
                return .run { send in
                    do {
                        let domain = ActionDomain(
                            id: actionID,
                            actionName: draft.actionName,
                            isVisible: draft.isVisible,
                            updatedAt: Date()
                        )

                        if isNew {
                            try await actionRepository.save(domain)
                        } else {
                            try await actionRepository.update(domain)
                        }

                        await send(.detail(.presented(.savingFinished)))
                        await send(.detail(.dismiss))

                    } catch {
                        await send(
                            .detail(
                                .presented(
                                    .saveFailed("保存に失敗しました。再度お試しください。")
                                )
                            )
                        )
                    }
                }
                
            case .detail(.presented(.delegate(.dismiss))):
                state.detail = nil
                return .none
                
            case .detail:
                return .none
            }
        }
        .ifLet(\.$detail, action: \.detail) {
            ActionSettingDetailReducer()
        }
    }
}

