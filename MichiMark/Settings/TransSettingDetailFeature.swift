import ComposableArchitecture
import Foundation

@Reducer
struct TransSettingDetailReducer {

    @ObservableState
    struct State: Equatable {
        let transID: TransID
        var transName: String = ""
        var kmPerGas: String = ""
        var meterValue: String = ""
        var isVisible: Bool = true
    }

    enum Action {
        case transNameChanged(String)
        case kmPerGasChanged(String)
        case meterValueChanged(String)

        case visibleToggled
        case saveTapped
        case backTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .transNameChanged(text):
                state.transName = text
                return .none

            case let .kmPerGasChanged(text):
                state.kmPerGas = text
                return .none

            case let .meterValueChanged(text):
                state.meterValue = text
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
