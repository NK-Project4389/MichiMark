import ComposableArchitecture
import Foundation

@Reducer
struct MichiInfoReducer {

    @ObservableState
    struct State: Equatable {
        var projection: MichiInfoListProjection
        var eventID: EventID
        var markDrafts: IdentifiedArrayOf<MarkDetailDraft>
        var linkDrafts: IdentifiedArrayOf<LinkDetailDraft>
        @Presents var addSheet: AddSheetReducer.State?
        
        init(
            projection: MichiInfoListProjection,
            eventID: EventID
        ) {
            self.projection = projection
            self.eventID = eventID
            self.markDrafts = []
            self.linkDrafts = []
            self.addSheet = nil
        }
    }

    enum Action {
        case appeared
        case markTapped(MarkLinkID)
        case linkTapped(MarkLinkID)
        case addButtonTapped
        case addSheet(PresentationAction<AddSheetReducer.Action>)
        
        case delegate(Delegate)

        enum Delegate {
            case openMarkDetail(EventID, MarkLinkID)
            case openLinkDetail(EventID, MarkLinkID)
            case addMarkOrLinkSelected(MarkOrLink)
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

            case .addButtonTapped:
                state.addSheet = AddSheetReducer.State()
                return .none

            case let .addSheet(.presented(.delegate(.selected(type)))):
                state.addSheet = nil
                return .send(.delegate(.addMarkOrLinkSelected(type)))
                
            case .addSheet(.presented(.delegate(.dismiss))),
                 .addSheet(.dismiss):
                state.addSheet = nil
                return .none
                
            case .addSheet:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$addSheet, action: \.addSheet) {
            AddSheetReducer()
        }
    }
}

extension MichiInfoReducer.State {
    var displayItems: [MarkLinkItemProjection] {
        let adapter = MarkLinkDraftProjectionAdapter()
        let markItems = markDrafts.map { adapter.adapt($0) }
        let linkItems = linkDrafts.map { adapter.adapt($0) }
        return (markItems + linkItems).sorted { lhs, rhs in
            lhs.markLinkSeq < rhs.markLinkSeq
        }
    }
}
