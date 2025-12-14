import ComposableArchitecture

struct BasicInfoReducer: Reducer {

    typealias State = BasicInfoState
    typealias Action = BasicInfoAction

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case let .eventDateChanged(date):
                state.eventDate = date
                return .none

            case let .eventNameChanged(text):
                state.eventName = text
                return .none

            case let .transNameChanged(text):
                state.transName = text
                return .none

            case .addMemberTapped:
                return .none

            case let .removeMember(name):
                state.memberNames.removeAll { $0 == name }
                if state.payMemberName == name {
                    state.payMemberName = nil
                }
                return .none

            case .addTagTapped:
                return .none

            case let .removeTag(tag):
                state.tagNames.removeAll { $0 == tag }
                return .none

            case let .kmPerGasChanged(text):
                state.kmPerGas = text.isEmpty ? nil : Double(text)
                return .none

            case let .gasPriceChanged(text):
                state.gasPrice = text.isEmpty ? nil : Int(text)
                return .none

            case .payMemberTapped:
                return .none

            case .appeared:
                return .none
            }
        }
    }
}
