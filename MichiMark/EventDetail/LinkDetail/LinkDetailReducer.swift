import ComposableArchitecture
import Foundation

@Reducer
struct LinkDetailReducer {

    @ObservableState
    struct State: Equatable {
        // 永続State
        var linkName: String = ""
        var members: [String] = []
        var distanceValue: String = ""
        var actionName: String = ""
        var memo: String = ""
        var fuelFlg: Bool = false
        var priceParGas: String = ""
        var gasQuentity: String = ""
        var gasPrice: String = ""

        // 外部依存
        var eventID: EventID
        var markLinkID: MarkLinkID
    }

    enum Action {
        case memberEditTapped
        case actionEditTapped
        case fuelEditTapped
        case saveTapped
        case backTapped

        case linkNameChanged(String)
        case distanceValueChanged(String)
        case memoValueChanged(String)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .linkNameChanged(text):
                state.linkName = text
                return .none
            case let .distanceValueChanged(text):
                state.distanceValue = text
                return .none
            case let .memoValueChanged(text):
                state.memo = text
                return .none
            default:
                return .none
            }
        }
    }
}
