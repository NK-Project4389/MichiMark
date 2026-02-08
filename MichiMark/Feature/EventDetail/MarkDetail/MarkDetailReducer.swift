import ComposableArchitecture
import Foundation


@Reducer
struct MarkDetailReducer {
    @ObservableState
    struct State {
        var markLinkID: MarkLinkID
        var projection: MarkLinkItemProjection
        var draft: MarkDetailDraft

        @Presents var datePicker: DatePickerReducer.State?
    }

    enum Action {
        // 既存
        case markLinkNameChanged(String)
        case meterValueChanged(String)
        case distanceValueChanged(String)
        case memoChanged(String)
        case dateTapped
        case datePicker(PresentationAction<DatePickerReducer.Action>)
        case membersTapped
        case actionsTapped
        case applyTapped
        case backTapped
        case memberSelectionResultReceived(Set<MemberID>, [MemberID: String])
        case actionSelectionResultReceived(Set<ActionID>, [ActionID: String])
        
        case fuelToggled(Bool)
        case fuel(FuelDetailReducer.Action)
        
        // MARK: - Delegate
        case delegate(Delegate)

        enum Delegate {
            case memberSelectionRequested(ids: Set<MemberID>)
            case actionSelectionRequested(ids: Set<ActionID>)
            case applied(MarkDetailDraft)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .dateTapped:
                state.datePicker = DatePickerReducer.State(date: state.draft.displayDateAsDate)
                return .none

            case let .datePicker(.presented(.delegate(.selected(date)))):
                state.draft.updateDisplayDate(date)
                state.datePicker = nil
                return .none
                
            case .membersTapped:
                return .send(
                    .delegate(.memberSelectionRequested(
                        ids: state.draft.selectedMemberIDs
                    ))
                )
                
            case .actionsTapped:
                return .send(
                    .delegate(.actionSelectionRequested(
                        ids: state.draft.selectedActionIDs
                    ))
                )

            case let .memberSelectionResultReceived(ids, names):
                state.draft.selectedMemberIDs = ids
                state.draft.selectedMemberNames = names
                return .none

            case let .actionSelectionResultReceived(ids, names):
                state.draft.selectedActionIDs = ids
                state.draft.selectedActionNames = names
                return .none

            case let .markLinkNameChanged(text):
                state.draft.markLinkName = text
                return .none

            case let .meterValueChanged(text):
                state.draft.displayMeterValue = text
                return .none

            case let .distanceValueChanged(text):
                state.draft.displayDistanceValue = text
                return .none

            case let .memoChanged(text):
                state.draft.memo = text
                return .none

            case .applyTapped:
                return .send(.delegate(.applied(state.draft)))

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
        .ifLet(\.$datePicker, action: \.datePicker) {
            DatePickerReducer()
        }

    }
}
