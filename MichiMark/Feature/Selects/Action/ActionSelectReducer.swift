import ComposableArchitecture
import Foundation

@Reducer
struct ActionSelectReducer {

    @ObservableState
    struct State: Equatable {
        var items: [ActionItemProjection]
        var selectedIDs: Set<ActionID>
        let useCase: ActionSelectionUseCase
        var isLoading = false
    }

    enum Action {
        case appeared
        case actionsResponse(TaskResult<[ActionDomain]>)
        case toggle(ActionID)
        case doneTapped
        case delegate(Delegate)
    }

    enum Delegate {
        case selected(ids: Set<ActionID>, names: [ActionID: String], useCase: ActionSelectionUseCase)
    }
    
    @Dependency(\.actionRepository) var actionRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .appeared:
                    state.isLoading = true
                    return .run { send in
                        await send(
                            .actionsResponse(
                                TaskResult {
                                    try await actionRepository.fetchAll()
                                }
                            )
                        )
                    }

            case let .actionsResponse(.success(domains)):
                let actionAdapter = ActionProjectionAdapter()
                state.isLoading = false
                state.items = domains
                    .filter { $0.isVisible }
                    .map{ actionAdapter.adapt($0) }
                return .none

            case .actionsResponse(.failure):
                state.isLoading = false
                state.items = []
                return .none
                
            case let .toggle(id):
                if state.selectedIDs.contains(id) {
                    state.selectedIDs.remove(id)
                } else {
                    state.selectedIDs.insert(id)
                }
                return .none
                
            case .doneTapped:
                let selectedNames: [ActionID: String] =
                        Dictionary(
                            uniqueKeysWithValues:
                                state.items
                                    .filter { state.selectedIDs.contains($0.id) }
                                    .map { ($0.id, $0.actionName) }
                        )
                return .send(.delegate(.selected(
                    ids: state.selectedIDs,
                    names: selectedNames,
                    useCase: state.useCase
                )))

            case .delegate:
                return .none
            }
        }
    }
}
