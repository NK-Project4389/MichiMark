import ComposableArchitecture
import Foundation

@Reducer
struct TagSettingReducer {

    @ObservableState
    struct State: Equatable {
        var tags: IdentifiedArrayOf<TagItemProjection> = []
    }

    enum Action {
        case tagSelected(TagID)
        case addTagTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}

