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

        // MARK: - Selection
        case applySelection(useCase: SelectionUseCase, ids: [UUID], names: [UUID: String])
        
        // MARK: - Delegate
        case delegate(Delegate)

        enum Delegate {
            case saveDraft(EventID, BasicInfoDraft)
            case selectionRequested(useCase: SelectionUseCase)
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
                    .delegate(.selectionRequested(useCase: .eventMembers))
                )
            
            case .payMemberTapped:
                return .send(
                    .delegate(.selectionRequested(useCase: .gasPayMember))
                )
                
            case .transTapped:
                return .send(.delegate(.selectionRequested(useCase: .eventTrans)))

            case .tagsTapped:
                return .send(.delegate(.selectionRequested(useCase: .eventTags)))
                
            case .saveTapped:
                return .send(
                    .delegate(.saveDraft(state.eventID, state.draft))
                )

            case let .applySelection(useCase, ids, names):
                switch useCase {
                case .eventTrans:
                    let id = ids.first
                    state.draft.selectedTransID = id
                    let name = id.flatMap { names[$0] }
                    state.draft.selectedTransName = name
                    state.projection = updatingTransProjection(
                        current: state.projection,
                        transID: id,
                        transName: name
                    )

                case .eventMembers:
                    state.draft.selectedMemberIDs = Set(ids)
                    state.draft.selectedMemberNames = names

                case .eventTags:
                    state.draft.selectedTagIDs = Set(ids)
                    state.draft.selectedTagNames = names

                case .gasPayMember:
                    let id = ids.first
                    state.draft.selectedPayMemberID = id
                    state.draft.selectedPayMemberName = id.flatMap { names[$0] }

                default:
                    break
                }
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private func updatingTransProjection(
        current: BasicInfoProjection,
        transID: TransID?,
        transName: String?
    ) -> BasicInfoProjection {
        let transProjection: TransItemProjection?
        if let transID, let transName {
            if let existing = current.trans, existing.id == transID {
                transProjection = TransItemProjection(
                    id: transID,
                    transName: transName,
                    displayKmPerGas: existing.displayKmPerGas,
                    displayMeterValue: existing.displayMeterValue,
                    isVisible: existing.isVisible
                )
            } else {
                transProjection = TransItemProjection(
                    id: transID,
                    transName: transName,
                    displayKmPerGas: "",
                    displayMeterValue: "",
                    isVisible: true
                )
            }
        } else {
            transProjection = nil
        }
        return BasicInfoProjection(
            id: current.id,
            eventName: current.eventName,
            trans: transProjection,
            tags: current.tags,
            members: current.members,
            kmPerGas: current.kmPerGas,
            displayKmPerGas: current.displayKmPerGas,
            pricePerGas: current.pricePerGas,
            displayPricePerGas: current.displayPricePerGas,
            payMember: current.payMember
        )
    }
}
