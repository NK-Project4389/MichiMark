import ComposableArchitecture
import Foundation

@Reducer
struct LinkDetailReducer {

    @ObservableState
    struct State: Equatable {
        var projection: MarkLinkItemProjection
        
        // 外部依存
        var eventID: EventID
        var markLinkID: MarkLinkID
        
        init(
            projection: MarkLinkItemProjection,
            eventID: EventID,
            markLinkID: MarkLinkID
        ) {
            self.projection = projection
            self.eventID = eventID
            self.markLinkID = markLinkID
        }
    }

    enum Action {
        case memberEditTapped
        case actionEditTapped
        case fuelEditTapped
        case saveTapped
        case backTapped

        case linkNameChanged(String)
        case distanceValueChanged(String)
        case memoValueChanged(String)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .linkNameChanged(text):
                return .none
            case let .distanceValueChanged(text):
                return .none
            case let .memoValueChanged(text):
                return .none
            default:
                return .none
            }
        }
    }
}
