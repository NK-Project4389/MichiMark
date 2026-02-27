import ComposableArchitecture
import Foundation

@Reducer
struct PaymentDetailReducer {

    @ObservableState
    struct State: Equatable {
        var projection: PaymentItemProjection?
        var draft: PaymentDraft
        
        // 外部依存
        var eventID: EventID?
        var paymentID: PaymentID?

        //@PresentationState var destination: Destination.State?
        
        init(
            projection: PaymentItemProjection,
            eventID: EventID,
            paymentID: PaymentID
        ) {
            self.projection = projection
            self.draft = PaymentDraft(projection: projection)
            self.eventID = eventID
            self.paymentID = paymentID
        }

        init(draft: PaymentDraft) {
            self.projection = nil
            self.draft = draft
            self.eventID = nil
            self.paymentID = nil
        }
    }

    enum Action {
        case paymentAmountChanged(String)
        case paymentMemoChanged(String)

        case payMemberTapped
        case payMemberSelectionRequested
        case payMemberSelectionResultReceived(MemberID?)

        case splitMembersTapped
        case splitMembersSelectionRequested
        case splitMembersSelectionResultReceived(Set<MemberID>)

        case selectionNamesReceived([MemberID: String])

        case applyButtonTapped
        case backTapped

        case delegate(Delegate)
    }

    enum Delegate {
        case selectionRequested(useCase: SelectionUseCase)
        case applied(PaymentDraft)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .paymentAmountChanged(text):
                // 変更理由: 数値以外は拒否し、空文字は nil に変換して Draft へ即時反映するため
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    state.draft.paymentAmount = nil
                    return .none
                }
                guard trimmed.allSatisfy({ $0.isNumber }) else {
                    return .none
                }
                guard let parsed = Int(trimmed) else {
                    return .none
                }
                state.draft.paymentAmount = parsed
                return .none

            case let .paymentMemoChanged(text):
                state.draft.paymentMemo = text
                return .none

            case .payMemberTapped:
                return .send(.payMemberSelectionRequested)

            case .payMemberSelectionRequested:
                return .send(.delegate(.selectionRequested(useCase: .payMember)))

            case let .payMemberSelectionResultReceived(memberID):
                let previousID = state.draft.payMemberID
                state.draft.payMemberID = memberID
                if previousID != memberID {
                    state.draft.payMemberName = nil
                }
                return .none

            case .splitMembersTapped:
                return .send(.splitMembersSelectionRequested)

            case .splitMembersSelectionRequested:
                return .send(.delegate(.selectionRequested(useCase: .splitMembers)))

            case let .splitMembersSelectionResultReceived(memberIDs):
                state.draft.splitMemberIDs = memberIDs
                // 変更理由: 選択結果に合わせて表示用の名前リストを安全に整理するため
                state.draft.splitMemberNames = state.draft.splitMemberNames.filter { memberIDs.contains($0.key) }
                return .none

            case let .selectionNamesReceived(names):
                if let payMemberID = state.draft.payMemberID {
                    state.draft.payMemberName = names[payMemberID] ?? state.draft.payMemberName
                } else {
                    state.draft.payMemberName = nil
                }

                if !state.draft.splitMemberIDs.isEmpty {
                    var updatedNames: [MemberID: String] = [:]
                    for memberID in state.draft.splitMemberIDs {
                        if let name = names[memberID] ?? state.draft.splitMemberNames[memberID] {
                            updatedNames[memberID] = name
                        }
                    }
                    state.draft.splitMemberNames = updatedNames
                }
                return .none

            case .applyButtonTapped:
                return .send(.delegate(.applied(state.draft)))

            default:
                return .none
            }
        }
    }
}
