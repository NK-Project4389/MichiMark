import ComposableArchitecture
import Foundation

@Reducer
struct TagSettingDetailReducer {

    @ObservableState
    struct State: Equatable {
        let tagID: TagID
        let projection: TagItemProjection
        var draft: TagDraft
        
        init(projection: TagItemProjection){
            self.tagID = TagID()
            self.projection = projection
            self.draft = TagDraft(projection: projection)
        }
    }

    enum Action {
        case tagNameChanged(String)

        case visibleToggled
        case saveTapped
        case backTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tagNameChanged(text):
                state.draft.tagName = text
                return .none

            case .visibleToggled:
                state.draft.isVisible.toggle()
                return .none

            case .saveTapped, .backTapped:
                return .none
            }
        }
    }
}
