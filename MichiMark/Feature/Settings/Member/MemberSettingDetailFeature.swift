import ComposableArchitecture
import Foundation

@Reducer
struct MemberSettingDetailReducer {

    @ObservableState
    struct State: Equatable {
        let memberID: MemberID
        var projection: MemberItemProjection
        var draft: MemberDraft
        
        init(projection: MemberItemProjection){
            self.memberID = MemberID()
            self.projection = projection
            self.draft = MemberDraft(projection: projection)
        }
    }

    enum Action {
        case memberNameChanged(String)

        case visibleToggled
        case saveTapped
        case backTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .memberNameChanged(text):
                state.draft.memberName = text
                return .none

            case .visibleToggled:
                state.draft.isVisible.toggle()
                return .none

            case .saveTapped, .backTapped:
                return .none
            }
        }
    }
}
