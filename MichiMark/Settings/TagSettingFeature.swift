import ComposableArchitecture
import Foundation

@Reducer
struct TagSettingReducer {

    @ObservableState
    struct State: Equatable {
        var tags: IdentifiedArrayOf<TagInfo> = []
    }

    enum Action {
        case tagSelected(TagInfo.ID)
        case addTagTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}

