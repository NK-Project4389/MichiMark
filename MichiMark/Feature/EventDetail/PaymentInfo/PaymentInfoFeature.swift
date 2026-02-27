import ComposableArchitecture
import Foundation

@Reducer
struct PaymentInfoReducer {

    @ObservableState
    struct State {
        var projection: PaymentInfoProjection
        var eventID: EventID
        
        init(
            projection: PaymentInfoProjection,
            eventID: EventID
        ) {
            self.projection = projection
            self.eventID = eventID
        }
    }

    struct Payment: Equatable, Identifiable {
        let id: UUID
        var amount: Int
        var paymentMember: String
        var splitMembers: [String]
        var memo: String
    }

    enum Action {
        case paymentTapped(PaymentID)
        case plusButtonTapped
        case delegate(Delegate)
    }

    enum Delegate {
        case openPaymentDetail(PaymentDraft)
        case openPaymentDetailByID(PaymentID)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .plusButtonTapped:
                return .send(
                    .delegate(
                        .openPaymentDetail(
                            PaymentDraft.initial()
                        )
                    )
                )

            case let .paymentTapped(paymentID):
                return .send(.delegate(.openPaymentDetailByID(paymentID)))

            case .delegate:
                return .none
            }
        }
    }
}
