import ComposableArchitecture
import Foundation

@Reducer
struct PaymentInfoReducer {

    @ObservableState
    struct State: Equatable {
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
        case paymentTapped(UUID)
        case addPaymentTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            .none
        }
    }
}
