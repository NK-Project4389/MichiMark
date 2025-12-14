import ComposableArchitecture

struct EventListReducer: Reducer {

    typealias State = EventListState
    typealias Action = EventListAction

    var body: some ReducerOf<Self> {

        // ① まず Reduce を書く
        Reduce { state, action in
            switch action {

            case .eventTapped, .addTapped:
                state.eventDetail = .mock()
                return .none

            case .eventDetail(.backButtonTapped):
                state.eventDetail = nil
                return .none

            default:
                return .none
            }
        }
        // ② その後に ifLet を「チェーン」する
        .ifLet(
            \.eventDetail,
            action: /EventListAction.eventDetail
        ) {
            EventDetail()
        }
    }
}
