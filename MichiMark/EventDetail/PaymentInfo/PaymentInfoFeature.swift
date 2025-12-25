import ComposableArchitecture
import Foundation

@Reducer
struct PaymentInfoReducer {

    @ObservableState
    struct State: Equatable {
        var payments: [Payment] = [
            .init(id: UUID(), amount: 1000, paymentMember: "テスト", splitMembers: ["テスト"], memo: "")
        ]
        let eventID: EventID
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
