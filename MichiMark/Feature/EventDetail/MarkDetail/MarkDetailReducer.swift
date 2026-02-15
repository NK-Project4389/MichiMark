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
        case applySelection(useCase: SelectionUseCase, ids: [UUID], names: [UUID: String])
        case applyTapped
        case backTapped
        
        case fuelToggled(Bool)
        case fuel(FuelDetailReducer.Action)
        
        // MARK: - Delegate
        case delegate(Delegate)

        enum Delegate {
            case selectionRequested(useCase: SelectionUseCase)
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
                    .delegate(.selectionRequested(useCase: .markMembers))
                )
                
            case .actionsTapped:
                return .send(
                    .delegate(.selectionRequested(useCase: .markActions))
                )

            case let .applySelection(useCase, ids, names):
                var shouldSyncProjection = false
                switch useCase {
                case .markMembers:
                    state.draft.selectedMemberIDs = Set(ids)
                    state.draft.selectedMemberNames = names
                    shouldSyncProjection = true

                case .markActions:
                    state.draft.selectedActionIDs = Set(ids)
                    state.draft.selectedActionNames = names
                    shouldSyncProjection = true

                default:
                    break
                }
                if shouldSyncProjection {
                    state.projection = state.draft.toProjection(id: state.markLinkID)
                }
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
