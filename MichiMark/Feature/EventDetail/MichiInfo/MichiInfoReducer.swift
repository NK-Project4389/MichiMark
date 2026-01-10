import ComposableArchitecture
import Foundation

@Reducer
struct MichiInfoReducer {

    @ObservableState
    struct State: Equatable {
        var projection: MichiInfoListProjection
        var eventID: EventID
        
        init(
            projection: MichiInfoListProjection,
            eventID: EventID
        ) {
            self.projection = projection
            self.eventID = eventID
        }
    }

    enum Action {
        case appeared
        case markTapped(MarkLinkID)
        case linkTapped(MarkLinkID)
        case addMarkTapped
        
        case delegate(Delegate)

        enum Delegate {
            case openMarkDetail(EventID, MarkLinkID)
            case openLinkDetail(EventID, MarkLinkID)
            case addMark(EventID)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .appeared:
                return .none

            case let .markTapped(id):
                return .send(.delegate(.openMarkDetail(state.eventID, id)))

            case let .linkTapped(id):
                return .send(.delegate(.openLinkDetail(state.eventID, id)))

            case .addMarkTapped:
                return .send(.delegate(.addMark(state.eventID)))

            case .delegate:
                return .none
            }
        }
    }
}
