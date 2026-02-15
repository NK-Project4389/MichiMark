import ComposableArchitecture
import Foundation

@Reducer
struct MemberSettingReducer {

    @ObservableState
    struct State {
        var members: IdentifiedArrayOf<MemberItemProjection> = []
        
        @Presents var detail: MemberSettingDetailReducer.State?
    }

    enum Action {
        case onAppear
        case membersLoaded([MemberDomain])
        
        case memberSelected(MemberID)
        case addMemberTapped
        case startCreate
        
        case detail(PresentationAction<MemberSettingDetailReducer.Action>)
    }
    
    @Dependency(\.memberRepository) var memberRepository

    var body: some ReducerOf<Self> {
        let memberAdapter = MemberProjectionAdapter()
        
        Reduce { state, action in
            switch action{
            case .onAppear:
                return .run { send in
                                let members = try await memberRepository.fetchAll()
                                await send(.membersLoaded(members))
                            }
                
            case let .membersLoaded(domains):
                state.members = IdentifiedArray(
                    uniqueElements: domains.map{ memberAdapter.adapt($0)}
                            )
                return .none
                
            case let .memberSelected(memberID):
                guard let projection = state.members[id: memberID] else {
                    return .none
                }
                state.detail = MemberSettingDetailReducer.State(projection: projection)
                return .none

            case .addMemberTapped:
                let newID = MemberID()
                let domain = MemberDomain(id: newID, memberName: "")
                let projection = memberAdapter.adapt(domain)
                state.detail = MemberSettingDetailReducer.State(projection: projection)
                return .none

            case .startCreate:
                let newID = MemberID()
                let domain = MemberDomain(id: newID, memberName: "")
                let projection = memberAdapter.adapt(domain)
                state.detail = MemberSettingDetailReducer.State(projection: projection)
                return .none
                
            case let .detail(.presented(.delegate(.saveRequested(memberID, draft)))):
                let isNew = state.members[id: memberID] == nil

                return .run { send in
                    do {
                        let domain = MemberDomain(
                            id: memberID,
                            memberName: draft.memberName,
                            isVisible: draft.isVisible,
                            updatedAt: Date()
                        )

                        if isNew {
                            try await memberRepository.save(domain)
                        } else {
                            try await memberRepository.update(domain)
                        }

                        await send(.detail(.presented(.savingFinished)))
                        await send(.detail(.dismiss))

                    } catch {
                        await send(
                            .detail(
                                .presented(
                                    .saveFailed("保存に失敗しました。再度お試しください。")
                                )
                            )
                        )
                    }
                }

            case .detail(.presented(.delegate(.dismiss))):
                state.detail = nil
                return .none
            case .detail:
                return .none
            }
        }
        .ifLet(\.$detail, action: \.detail) {
            MemberSettingDetailReducer()
        }
    }
}
