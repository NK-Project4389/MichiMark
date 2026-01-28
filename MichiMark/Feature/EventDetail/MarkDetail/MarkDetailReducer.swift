import ComposableArchitecture
import Foundation

@Reducer
struct MarkDetailReducer {

    @ObservableState
    struct State: Equatable {
        var projection: MarkLinkItemProjection
        var draft: MarkDetailDraft
        var eventID: EventID
        var markLinkID: MarkLinkID
    }

    enum Action {
        // 既存
        case markLinkNameChanged(String)
        case meterValueChanged(String)
        case distanceValueChanged(String)
        case memoChanged(String)
        case dateTapped
        case membersTapped
        case actionsTapped
        case saveTapped
        case backTapped

        // 給油
        case fuelToggled(Bool)
        case fuel(FuelDetailReducer.Action)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case let .fuelToggled(isOn):
                state.draft.isFuel = isOn
                if isOn && state.draft.fuelDetail == nil {
                    state.draft.fuelDetail = FuelDetailReducer.State(
                        pricePerGas: "",
                        gasQuantity: "",
                        gasPrice: ""
                    )
                }
                if !isOn {
                    state.draft.fuelDetail = nil
                }
                return .none

            case .fuel(.clearTapped):
                state.draft.fuelDetail = FuelDetailReducer.State(
                    pricePerGas: "",
                    gasQuantity: "",
                    gasPrice: ""
                )
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.draft.fuelDetail, action: \.fuel) {
            FuelDetailReducer()
        }
    }
}
