import ComposableArchitecture
import Foundation

@Reducer
struct OverviewReducer {
    @ObservableState struct State: Equatable { }
    enum Action { }
    var body: some ReducerOf<Self> { EmptyReducer() }
}
