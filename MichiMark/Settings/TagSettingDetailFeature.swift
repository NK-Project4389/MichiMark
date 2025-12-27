import ComposableArchitecture
import Foundation

@Reducer
struct TagSettingDetailReducer {

    @ObservableState
    struct State: Equatable {
        let tagID: TagID
        var tagName: String = ""
        var isVisible: Bool = true
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
                state.tagName = text
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
