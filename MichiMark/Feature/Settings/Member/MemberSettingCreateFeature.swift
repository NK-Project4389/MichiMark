import ComposableArchitecture
import Foundation

@Reducer
struct MemberSettingCreateReducer {

    @ObservableState
    struct State {
        var detail: MemberSettingDetailReducer.State

        init() {
            let newID = MemberID()
            let domain = MemberDomain(id: newID, memberName: "")
            let projection = MemberProjectionAdapter().adapt(domain)
            self.detail = MemberSettingDetailReducer.State(projection: projection)
        }
    }

    enum Action {
        case detail(MemberSettingDetailReducer.Action)
    }

    @Dependency(\.memberRepository) var memberRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .detail(.delegate(.saveRequested(memberID, draft))):
                let domain = MemberDomain(
                    id: memberID,
                    memberName: draft.memberName,
                    isVisible: draft.isVisible,
                    updatedAt: Date()
                )
                return .run { send in
                    do {
                        try await memberRepository.save(domain)
                        await send(.detail(.savingFinished))
                    } catch {
                        await send(
                            .detail(
                                .saveFailed("保存に失敗しました。再度お試しください。")
                            )
                        )
                    }
                }

            default:
                return .none
            }
        }
        Scope(state: \.detail, action: \.detail) {
            MemberSettingDetailReducer()
        }
    }
}
