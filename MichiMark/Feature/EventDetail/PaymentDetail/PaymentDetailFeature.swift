import ComposableArchitecture
import Foundation

@Reducer
struct PaymentDetailReducer {

    @ObservableState
    struct State: Equatable {
        var projection: PaymentItemProjection
        var draft: PaymentDraft
        
        // 外部依存
        var eventID: EventID
        var paymentID: PaymentID

        //@PresentationState var destination: Destination.State?
        
        init(
            projection: PaymentItemProjection,
            eventID: EventID,
            paymentID: PaymentID
        ) {
            self.projection = projection
            self.draft = PaymentDraft(projection: projection)
            self.eventID = eventID
            self.paymentID = paymentID
        }
    }

    enum Action {
        case paymentAmountChanged(String)
        case paymentMemoChanged(String)

        case paymentMemberEditTapped
        case splitMemberEditTapped

        case applySelection(useCase: SelectionUseCase, ids: [UUID], names: [UUID: String])

        case saveTapped
        case backTapped

        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
    }

    enum Delegate {
        case selectionRequested(useCase: SelectionUseCase)
    }

    @Reducer
    struct Destination {
        enum State: Equatable {
            case paymentMemberSelection
            case splitMemberSelection
        }
        enum Action {}
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .paymentMemberEditTapped:
                return .send(.delegate(.selectionRequested(useCase: .payMember)))

            case .splitMemberEditTapped:
                return .send(.delegate(.selectionRequested(useCase: .splitMembers)))

            case let .applySelection(useCase, ids, names):
                switch useCase {
                case .payMember:
                    state.draft.payMemberID = ids.first
                    state.draft.payMemberName = ids.first.flatMap { names[$0] }

                case .splitMembers:
                    state.draft.splitMemberIDs = Set(ids)
                    state.draft.splitMemberNames = names

                default:
                    break
                }
                return .none

            default:
                return .none
            }
        }
        //.ifLet(\.$destination, action: \.destination)
    }
}
