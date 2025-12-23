import ComposableArchitecture
import Foundation

@Reducer
struct MichiInfoReducer {

    @ObservableState
    struct State: Equatable {
        var markLinks: [MarkLinkInfo] = [
            .init(id: UUID(), kind: .mark, markLinkName: "休憩ポイント"),
            .init(id: UUID(), kind: .link, markLinkName: "link"),
            .init(id: UUID(), kind: .mark, markLinkName: "給油"),
        ]

        var eventID: EventID
    }

    enum Action {
        case appeared
        case markTapped(MarkLinkID)
        case linkTapped(MarkLinkID)
        case addMarkTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .appeared, .markTapped, .linkTapped, .addMarkTapped:
                // 上位(EventDetail)が受けて遷移する
                return .none
            }
        }
    }
}
