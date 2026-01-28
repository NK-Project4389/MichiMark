import ComposableArchitecture
import Foundation

@Reducer
struct TagSettingReducer {

    @ObservableState
    struct State {
        var tags: IdentifiedArrayOf<TagItemProjection> = []
        
        @Presents var detail: TagSettingDetailReducer.State?
    }

    enum Action {
        case onAppear
        case tagsLoaded([TagDomain])
        
        case tagSelected(TagID)
        case addTagTapped
        
        case detail(PresentationAction<TagSettingDetailReducer.Action>)
    }
    
    @Dependency(\.tagRepository) var tagRepository

    var body: some ReducerOf<Self> {
        let tagAdapter = TagProjectionAdapter()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let tags = try await tagRepository.fetchAll()
                    await send(.tagsLoaded(tags))
                }
                
            case let .tagsLoaded(domains):
                state.tags = IdentifiedArray(
                    uniqueElements: domains.map{ tagAdapter.adapt($0) }
                    )
                return .none
                
            case let .tagSelected(tagID):
                guard let projection = state.tags[id: tagID] else {
                    return .none
                }
                state.detail = TagSettingDetailReducer.State(projection: projection)
                return .none
                
            case .addTagTapped:
                let newID = TagID()
                let domain = TagDomain(id: newID, tagName: "")
                let projection = tagAdapter.adapt(domain)
                state.detail = TagSettingDetailReducer.State(projection: projection)
                return .none
                
            case let .detail(.presented(.delegate(.saveRequested(tagID, draft)))):
                let isNew = state.tags[id: tagID] == nil

                return .run { send in
                    do {
                        let domain = TagDomain(
                            id: tagID,
                            tagName: draft.tagName,
                            isVisible: draft.isVisible,
                            updatedAt: Date()
                        )

                        if isNew {
                            try await tagRepository.save(domain)
                        } else {
                            try await tagRepository.update(domain)
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
            TagSettingDetailReducer()
        }
    }
}

