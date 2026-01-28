import ComposableArchitecture
import Foundation

@Reducer
struct TransSelectReducer {

    @ObservableState
    struct State: Equatable {
        var items: [TransItemProjection]
        var selectedID: TransID?
        var isLoading = false
    }

    enum Action {
        case appeared
        case transResponse(TaskResult<[TransDomain]>)
        
        case select(TransID)
        case doneTapped
        case delegate(Delegate)
    }

    enum Delegate {
        case selected(id: TransID?, name: String?)
    }
    
    @Dependency(\.transRepository) var transRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .appeared:
                    state.isLoading = true
                    return .run { send in
                        await send(
                            .transResponse(
                                TaskResult {
                                    try await transRepository.fetchAll()
                                }
                            )
                        )
                    }

            case let .transResponse(.success(domains)):
                let transAdapter = TransProjectionAdapter()
                state.isLoading = false
                state.items = domains
                    .filter { $0.isVisible }
                    .map { transAdapter.adapt($0) }
                return .none

            case .transResponse(.failure):
                state.isLoading = false
                state.items = []
                return .none
                
            case let .select(id):
                state.selectedID = id
                return .none

            case .doneTapped:
                let selected = state.items.first { $0.id == state.selectedID }
                return .send(
                    .delegate(
                        .selected(
                            id: selected?.id,
                            name: selected?.transName
                        )
                    )
                )

            case .delegate:
                return .none
            }
        }
    }
}
