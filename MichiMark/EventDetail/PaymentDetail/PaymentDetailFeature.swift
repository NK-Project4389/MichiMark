import ComposableArchitecture
import Foundation

@Reducer
struct PaymentDetailReducer {

    @ObservableState
    struct State: Equatable {
        // 外部依存
        var eventID: EventID
        var paymentID: PaymentID

        var amount: Int = 0
        var paymentMember: String = ""
        var splitMembers: [String] = []
        var memo: String = ""

        //@PresentationState var destination: Destination.State?
    }

    enum Action {
        case paymentAmountChanged(String)
        case paymentMemoChanged(String)

        case paymentMemberEditTapped
        case splitMemberEditTapped

        case saveTapped
        case backTapped

        case destination(PresentationAction<Destination.Action>)
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
                //state.destination = .paymentMemberSelection
                return .none

            case .splitMemberEditTapped:
                //state.destination = .splitMemberSelection
                return .none

            default:
                return .none
            }
        }
        //.ifLet(\.$destination, action: \.destination)
    }
}
