import ComposableArchitecture
import Foundation

@Reducer
struct MemberSelectReducer {

    enum SelectionMode: Equatable {
        case multiple
        case single
    }
    
    @ObservableState
    struct State: Equatable {
        var items: [MemberItemProjection]
        var selectedIDs: Set<MemberID>
        let mode: SelectionMode
        let useCase: MemberSelectionUseCase
        var isLoading = false
    }

    enum Action {
        case appeared
        case membersResponse(TaskResult<[MemberDomain]>)
        
        case toggle(MemberID)
        case doneTapped
        case delegate(Delegate)
    }

    enum Delegate {
        case selected(ids: Set<MemberID>, names: [MemberID: String], useCase: MemberSelectionUseCase)
    }
    
    @Dependency(\.memberRepository) var memberRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            
            switch action {

            case .appeared:
                    state.isLoading = true
                    return .run { send in
                        await send(
                            .membersResponse(
                                TaskResult {
                                    try await memberRepository.fetchAll()
                                }
                            )
                        )
                    }

            case let .membersResponse(.success(domains)):
                let memberAdapter = MemberProjectionAdapter()
                state.isLoading = false
                state.items = domains
                    .filter { $0.isVisible }
                    .map{ memberAdapter.adapt($0) }
                return .none

            case .membersResponse(.failure):
                state.isLoading = false
                state.items = []
                return .none
                
            case let .toggle(id):
                switch state.mode {
                case .multiple:
                    if state.selectedIDs.contains(id) {
                        state.selectedIDs.remove(id)
                    } else {
                        state.selectedIDs.insert(id)
                    }

                case .single:
                    state.selectedIDs = [id]     // ★ 常に1つ
                }
                return .none


            case .doneTapped:
                let selectedNames: [MemberID: String] =
                        Dictionary(
                            uniqueKeysWithValues:
                                state.items
                                    .filter { state.selectedIDs.contains($0.id) }
                                    .map { ($0.id, $0.memberName) }
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
