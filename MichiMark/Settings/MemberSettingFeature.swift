import ComposableArchitecture
import Foundation

@Reducer
struct MemberSettingReducer {

    @ObservableState
    struct State: Equatable {
        var members: IdentifiedArrayOf<MemberInfo> = []
    }

    enum Action {
        case memberSelected(MemberInfo.ID)
        case addMemberTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}

