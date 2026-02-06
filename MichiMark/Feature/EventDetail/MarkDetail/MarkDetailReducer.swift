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
        
        case fuelToggled(Bool)
        case fuel(FuelDetailReducer.Action)
        
        // MARK: - Delegate
        case delegate(Delegate)

        enum Delegate {
            case membersSelectionRequested(
                ids: Set<MemberID>,
                useCase: MemberSelectionUseCase,
                mode: MemberSelectReducer.SelectionMode
            )
            case actionsSelectionRequested(
                ids: Set<ActionID>,
                useCase: ActionSelectionUseCase
            )
            case applied(MarkLinkID, MarkDetailDraft)
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
                    .delegate(.membersSelectionRequested(
                        ids: state.draft.selectedMemberIDs,
                        useCase: .markMembers,
                        mode: .multiple
                    ))
                )
                
            case .actionsTapped:
                return .send(
                    .delegate(.actionsSelectionRequested(
                        ids: state.draft.selectedActionIDs,
                        useCase: .markActions
                    ))
                )

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
                return .send(.delegate(.applied(state.markLinkID, state.draft)))

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
