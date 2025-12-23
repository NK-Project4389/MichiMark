import ComposableArchitecture
import Foundation

@Reducer
struct LinkDetailReducer {
    @ObservableState
    struct State: Equatable {
        var eventID: EventID
        var markLinkID: MarkLinkID
    }
    enum Action { case appeared }
    var body: some ReducerOf<Self> { Reduce { _, _ in .none } }
}

@Reducer
struct SettingsReducer {
    @ObservableState struct State: Equatable { }
    enum Action { case appeared }
    var body: some ReducerOf<Self> { Reduce { _, _ in .none } }
}

@Reducer
struct PaymentInfoReducer {
    @ObservableState struct State: Equatable { }
    enum Action { }
    var body: some ReducerOf<Self> { Reduce { _, _ in .none } }
}

@Reducer
struct SummaryReducer {
    @ObservableState struct State: Equatable { }
    enum Action { }
    var body: some ReducerOf<Self> { Reduce { _, _ in .none } }
}

@Reducer
struct RouteInfoReducer {
    @ObservableState struct State: Equatable { }
    enum Action { }
    var body: some ReducerOf<Self> { Reduce { _, _ in .none } }
}
