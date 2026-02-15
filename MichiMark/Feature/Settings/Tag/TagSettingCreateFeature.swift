import ComposableArchitecture
import Foundation

@Reducer
struct TagSettingCreateReducer {

    @ObservableState
    struct State {
        var detail: TagSettingDetailReducer.State

        init() {
            let newID = TagID()
            let domain = TagDomain(id: newID, tagName: "")
            let projection = TagProjectionAdapter().adapt(domain)
            self.detail = TagSettingDetailReducer.State(projection: projection)
        }
    }

    enum Action {
        case detail(TagSettingDetailReducer.Action)
    }

    @Dependency(\.tagRepository) var tagRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .detail(.delegate(.saveRequested(tagID, draft))):
                let domain = TagDomain(
                    id: tagID,
                    tagName: draft.tagName,
                    isVisible: draft.isVisible,
                    updatedAt: Date()
                )
                return .run { send in
                    do {
                        try await tagRepository.save(domain)
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
            TagSettingDetailReducer()
        }
    }
}
