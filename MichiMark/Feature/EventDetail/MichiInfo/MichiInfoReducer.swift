import ComposableArchitecture
import Foundation

@Reducer
struct MichiInfoReducer {

    @ObservableState
    struct State: Equatable {
        var projection: MichiInfoListProjection
        var eventID: EventID
        var draftByID: [MarkLinkID: MarkDetailDraft]
        var linkDraftByID: [MarkLinkID: LinkDetailDraft]
        
        init(
            projection: MichiInfoListProjection,
            eventID: EventID
        ) {
            self.projection = projection
            self.eventID = eventID
            self.draftByID = [:]
            self.linkDraftByID = [:]
        }
    }

    enum Action {
        case appeared
        case markTapped(MarkLinkID)
        case linkTapped(MarkLinkID)
        case addMarkTapped
        case markDetailDraftApplied(MarkLinkID, MarkDetailDraft)
        case linkDetailDraftApplied(MarkLinkID, LinkDetailDraft)
        
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

            case let .markDetailDraftApplied(markLinkID, draft):
                state.draftByID[markLinkID] = draft
                return .none
                
            case let .linkDetailDraftApplied(markLinkID, draft):
                state.linkDraftByID[markLinkID] = draft
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

extension MichiInfoReducer.State {
    var displayItems: [MarkLinkItemProjection] {
        projection.items.map { item in
            if item.markLinkType == .link, let draft = linkDraftByID[item.id] {
                return draft.toProjection(id: item.id)
            }
            if item.markLinkType == .mark, let draft = draftByID[item.id] {
                return draft.toProjection(id: item.id)
            }
            return item
        }
    }
}
