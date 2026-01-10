import ComposableArchitecture
import Foundation

@Reducer
struct TransSettingDetailReducer {

    @ObservableState
    struct State: Equatable {
        let transID: TransID
        let projection: TransItemProjection
        var draft: TransDraft
        
        init(projection: TransItemProjection){
            self.transID = TransID()
            self.projection = projection
            self.draft = TransDraft(projection: projection)
        }
    }

    enum Action {
        case transNameChanged(String)
        case kmPerGasChanged(String)
        case meterValueChanged(String)

        case visibleToggled
        case saveTapped
        case backTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .transNameChanged(text):
                state.draft.transName = text
                return .none

            case let .kmPerGasChanged(text):
                state.draft.displayKmPerGas = text
                return .none

            case let .meterValueChanged(text):
                state.draft.displayMeterValue = text
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
