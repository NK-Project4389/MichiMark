import ComposableArchitecture

@Reducer
struct PaymentInfo {
    struct State: Equatable {
        init() {}
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        Reduce { _, _ in .none }
    }
}
