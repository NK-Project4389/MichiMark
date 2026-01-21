import ComposableArchitecture
import Foundation

@Reducer
struct ActionSelectReducer {

    @ObservableState
    struct State: Equatable {
        /// 表示用（候補）
        var items: [ActionItemProjection]

        /// 選択中（Draft に反映される）
        var selectedIDs: Set<ActionID>
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
        case selected(ids: Set<ActionID>, names: [ActionID: String])
    }
    
    @Dependency(\.actionRepository) var actionsRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .appeared:
                    state.isLoading = true
                    return .run { send in
                        await send(
                            .actionsResponse(
                                TaskResult {
                                    try await actionsRepository.fetchAll()
                                }
                            )
                        )
                    }

            case let .actionsResponse(.success(domains)):
                state.isLoading = false
                state.items = domains
                    .filter { $0.isVisible }
                    .map(ActionItemProjection.init)
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
                    names: selectedNames
                )))

            case .delegate:
                return .none
            }
        }
    }
}
