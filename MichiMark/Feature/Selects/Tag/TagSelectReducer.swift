import ComposableArchitecture
import Foundation

@Reducer
struct TagSelectReducer {

    @ObservableState
    struct State: Equatable {
        var items: [TagItemProjection]
        var selectedIDs: Set<TagID>
        var isLoading = false
    }

    enum Action {
        case appeared
        case tagsResponse(TaskResult<[TagDomain]>)
        
        case toggle(TagID)
        case doneTapped
        case delegate(Delegate)
    }

    enum Delegate {
        case selected(ids: Set<TagID>, names: [TagID: String])
    }
    
    @Dependency(\.tagRepository) var tagsRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .appeared:
                    state.isLoading = true
                    return .run { send in
                        await send(
                            .tagsResponse(
                                TaskResult {
                                    try await tagsRepository.fetchAll()
                                }
                            )
                        )
                    }

            case let .tagsResponse(.success(domains)):
                state.isLoading = false
                state.items = domains
                    .filter { $0.isVisible }
                    .map(TagItemProjection.init)
                return .none

            case .tagsResponse(.failure):
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
                let selectedNames: [TagID: String] =
                        Dictionary(
                            uniqueKeysWithValues:
                                state.items
                                    .filter { state.selectedIDs.contains($0.id) }
                                    .map { ($0.id, $0.tagName) }
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
