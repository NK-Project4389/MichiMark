import ComposableArchitecture
import Foundation

@Reducer
struct MarkDetailReducer {

    @ObservableState
    struct State: Equatable {
        // 永続State
        var markName: String = ""
        var members: [String] = []
        var meterValue: String = ""
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

        case markNameChanged(String)
        case meterValueChanged(String)
        case memoValueChanged(String)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .markNameChanged(text):
                state.markName = text
                return .none
            case let .meterValueChanged(text):
                state.meterValue = text
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
