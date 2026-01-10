import ComposableArchitecture
import Foundation

@Reducer
struct MemberSettingReducer {

    @ObservableState
    struct State: Equatable {
        var members: IdentifiedArrayOf<MemberItemProjection> = []
    }

    enum Action {
        case memberSelected(MemberID)
        case addMemberTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}

