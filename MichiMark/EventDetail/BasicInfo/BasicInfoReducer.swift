import ComposableArchitecture
import Foundation

@Reducer
struct BasicInfoReducer {

    @ObservableState
    struct State: Equatable {
        // 永続State
        var eventDate: Date = Date()
        var eventName: String = ""
        var transName: String = ""
        var memberNames: [String] = []
        var tagNames: [String] = []
        var kmPerGas: Double? = nil
        var gasPrice: Int? = nil
        var payMemberName: String? = nil

        // 外部依存
        var eventID: EventID
    }

    enum Action {
        // タップ
        case transEditTapped
        case memberEditTapped
        case tagEditTapped
        case payMemberEditTapped
        case saveTapped
        case backTapped

        // 入力
        case eventDateTapped
        case eventDateChanged(Date)
        case eventNameChanged(String)
        case kmPerGasChanged(String)
        case gasPriceChanged(String)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .eventDateChanged(date):
                state.eventDate = date
                return .none
            case let .eventNameChanged(text):
                state.eventName = text
                return .none
            case let .kmPerGasChanged(text):
                state.kmPerGas = Double(text)
                return .none
            case let .gasPriceChanged(text):
                state.gasPrice = Int(text)
                return .none
            default:
                return .none
            }
        }
    }
}
