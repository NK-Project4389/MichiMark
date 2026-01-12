import ComposableArchitecture
import Foundation

@Reducer
struct TransSettingReducer {

    @ObservableState
    struct State {
        var transes: IdentifiedArrayOf<TransItemProjection> = []
        
        @Presents var detail: TransSettingDetailReducer.State?
    }

    enum Action {
        case onAppear
        case transesLoaded([TransDomain])
        
        case transSelected(TransID)
        case addTransTapped
        
        case detail(PresentationAction<TransSettingDetailReducer.Action>)
    }
    
    @Dependency(\.transRepository) var transRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let transes = try await transRepository.fetchAll()
                    await send(.transesLoaded(transes))
                }
                
            case let .transesLoaded(domains):
                state.transes = IdentifiedArray(
                    uniqueElements: domains.map(TransItemProjection.init)
                    )
                return .none
                
            case let .transSelected(transID):
                guard let projection = state.transes[id: transID] else {
                    return .none
                }
                state.detail = TransSettingDetailReducer.State(projection: projection)
                return .none
                
            case .addTransTapped:
                let domain = TransDomain(id: UUID(), transName: "")
                let projection = TransItemProjection(domain: domain)
                state.detail = TransSettingDetailReducer.State(projection: projection)
                return .none
                
            case let .detail(.presented(.delegate(.saveRequested(transID, draft)))):
                let isNew = state.transes[id: transID] == nil
                let domain = draft.toDomain(id: transID)

                return .run { send in
                    do {
                        if isNew {
                            try await transRepository.save(domain)
                        } else {
                            try await transRepository.update(domain)
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
            TransSettingDetailReducer()
        }
    }
}

