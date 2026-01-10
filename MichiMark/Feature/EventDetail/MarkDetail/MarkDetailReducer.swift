import ComposableArchitecture
import Foundation

@Reducer
struct MarkDetailReducer {

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

    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
    }
}
