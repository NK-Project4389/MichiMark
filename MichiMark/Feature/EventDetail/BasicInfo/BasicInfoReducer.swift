import ComposableArchitecture
import Foundation

@Reducer
struct BasicInfoReducer {

    @ObservableState
    struct State: Equatable {

        /// 保存済み表示用
        var projection: BasicInfoProjection

        /// 入力途中
        var draft: BasicInfoDraft

        /// 外部依存
        var eventID: EventID

        init(
            projection: BasicInfoProjection,
            eventID: EventID
        ) {
            self.projection = projection
            self.eventID = eventID

            self.draft = BasicInfoDraft(
                eventName: projection.eventName,

                selectedTransID: projection.trans?.id,

                selectedTagIDs: Set(projection.tags.map(\.id)),
                selectedMemberIDs: Set(projection.members.map(\.id)),
                
                selectedTagNames: [:],
                selectedMemberNames: [:],

                kmPerGas: projection.kmPerGas.map { String(Double($0) / 10.0) } ?? "",
                pricePerGas: projection.pricePerGas.map(String.init) ?? "",

                selectedPayMemberID: projection.payMember?.id
            )
        }

    }

    enum Action {

        // MARK: - Input
        case eventNameChanged(String)
        case kmPerGasChanged(String)
        case pricePerGasChanged(String)

        // MARK: Tap（遷移トリガ）
        case transTapped
        case membersTapped
        case tagsTapped
        case payMemberTapped
        
        // MARK: - Tap
        case saveTapped
        
        // MARK: - Delegate
        case delegate(Delegate)

        enum Delegate {
            case saveDraft(EventID, BasicInfoDraft)
            case membersSelectionRequested(ids: Set<MemberID>, useCase: MemberSelectionUseCase)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case let .eventNameChanged(text):
                state.draft.eventName = text
                return .none

            case let .kmPerGasChanged(text):
                state.draft.kmPerGas = text
                return .none

            case let .pricePerGasChanged(text):
                state.draft.pricePerGas = text
                return .none

            case .membersTapped:
                return .send(
                    .delegate(.membersSelectionRequested(
                        ids: state.draft.selectedMemberIDs,
                        useCase: .totalMembers
                    ))
                )
            
            case .payMemberTapped:
                return .send(
                    .delegate(.membersSelectionRequested(
                        ids: state.draft.selectedPayMemberID.map{ [$0] } ?? [],
                        useCase: .gasPayer
                    ))
                )
                
            case .transTapped,  .tagsTapped:
                return .none
                
            case .saveTapped:
                return .send(
                    .delegate(.saveDraft(state.eventID, state.draft))
                )

            case .delegate:
                return .none
            }
        }
    }
}
