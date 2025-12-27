import ComposableArchitecture
import Foundation

@Reducer
struct MemberSettingDetailReducer {

    @ObservableState
    struct State: Equatable {
        let memberID: MemberID
        var memberName: String = ""
        var isVisible: Bool = true
    }

    enum Action {
        case memberNameChanged(String)

        case visibleToggled
        case saveTapped
        case backTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .memberNameChanged(text):
                state.memberName = text
                return .none

            case .visibleToggled:
                state.isVisible.toggle()
                return .none

            case .saveTapped, .backTapped:
                return .none
            }
        }
    }
}
