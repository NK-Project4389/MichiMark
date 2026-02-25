import ComposableArchitecture
import Foundation


@Reducer
struct LinkDetailReducer {
    @ObservableState
    struct State {
        var markLinkID: MarkLinkID
        var projection: MarkLinkItemProjection
        var draft: LinkDetailDraft
    }

    enum Action {
        // 既存
        case markLinkNameChanged(String)
        case distanceValueChanged(String)
        case memoChanged(String)
        case dateTapped
        case dateSelected(Date)
        case membersTapped
        case actionsTapped
        case applySelection(useCase: SelectionUseCase, ids: [UUID], names: [UUID: String])
        case reflectButtonTapped
        case backTapped

        case fuelToggled(Bool)
        case fuel(FuelDetailReducer.Action)

        // MARK: - Delegate
        case delegate(Delegate)

        enum Delegate {
            case selectionRequested(useCase: SelectionUseCase)
            case datePickerRequested
            case saved(LinkDetailDraft)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .dateTapped:
                return .send(.delegate(.datePickerRequested))

            case let .dateSelected(date):
                state.draft.updateDisplayDate(date)
                return .none

            case .membersTapped:
                return .send(
                    .delegate(.selectionRequested(useCase: .linkMembers))
                )

            case .actionsTapped:
                return .send(
                    .delegate(.selectionRequested(useCase: .linkActions))
                )

            case let .applySelection(useCase, ids, names):
                var shouldSyncProjection = false
                switch useCase {
                case .linkMembers:
                    state.draft.selectedMemberIDs = Set(ids)
                    state.draft.selectedMemberNames = names
                    shouldSyncProjection = true

                case .linkActions:
                    state.draft.selectedActionIDs = Set(ids)
                    state.draft.selectedActionNames = names
                    shouldSyncProjection = true

                default:
                    break
                }
                if shouldSyncProjection {
                    state.projection = state.draft.toProjection()
                }
                return .none

            case let .markLinkNameChanged(text):
                state.draft.markLinkName = text
                return .none

            case let .distanceValueChanged(text):
                state.draft.displayDistanceValue = text
                return .none

            case let .memoChanged(text):
                state.draft.memo = text
                return .none

            case .reflectButtonTapped:
//                return .send(.delegate(.applied(state.draft)))
//                return .concatenate(
//                          .send(.delegate(.applied(state.draft))),
//                          .run { _ in
//                            await dismiss()            // ← applied の後に閉じる
//                          }
//                        )
                return .send(.delegate(.saved(state.draft)))

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
