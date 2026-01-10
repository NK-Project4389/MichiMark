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
                kmPerGas: projection.displayKmPerGas,
                pricePerGas: projection.displayPricePerGas
            )
        }
    }

    enum Action {

        // MARK: - Input
        case eventNameChanged(String)
        case kmPerGasChanged(String)
        case pricePerGasChanged(String)

        // MARK: - Tap
        case saveTapped
        
        // MARK: - Delegate
        case delegate(Delegate)

        enum Delegate {
            case saveDraft(EventID, BasicInfoDraft)
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

            case .saveTapped:
                //return .send(
                //    .delegate(.saveDraft(state.eventID, state.draft))
                //)
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
