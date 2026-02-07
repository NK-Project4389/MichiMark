import ComposableArchitecture
import Foundation


@Reducer
struct MarkDetailReducer {
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State {
        
        var projection: MarkLinkItemProjection
        var draft: MarkDetailDraft
        
        @Presents var destination: Destination.State?
        @Presents var datePicker: DatePickerReducer.State?
    }

    @Reducer
    enum Destination {
        case memberSelection(SelectionFeature<MemberID>)
        case actionSelection(SelectionFeature<ActionID>)
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
        case destination(PresentationAction<Destination.Action>)
        
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

            case let .destination(.presented(.memberSelection(.delegate(.selected(ids))))):
                guard case let .memberSelection(selectionState) = state.destination else { return .none }
                let names = Dictionary(
                    uniqueKeysWithValues: selectionState.items
                        .filter { ids.contains($0.id) }
                        .map { ($0.id, $0.title) }
                )
                state.draft.selectedMemberIDs = ids
                state.draft.selectedMemberNames = names
//                state.destination = nil
                return .none

            case .destination(.presented(.memberSelection(.delegate(.cancelled)))):
//                state.destination = nil
                return .none

            case let .destination(.presented(.actionSelection(.delegate(.selected(ids))))):
                guard case let .actionSelection(selectionState) = state.destination else { return .none }
                let names = Dictionary(
                    uniqueKeysWithValues: selectionState.items
                        .filter { ids.contains($0.id) }
                        .map { ($0.id, $0.title) }
                )
                state.draft.selectedActionIDs = ids
                state.draft.selectedActionNames = names
//                state.destination = nil
                return .none

            case .destination(.presented(.actionSelection(.delegate(.cancelled)))):
//                state.destination = nil
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
//                return .send(.delegate(.applied(state.draft)))
                return .concatenate(
                          .send(.delegate(.applied(state.draft))),
                          .run { _ in
                            await dismiss()            // ← applied の後に閉じる
                          }
                        )

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
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$datePicker, action: \.datePicker) {
            DatePickerReducer()
        }

    }
}
