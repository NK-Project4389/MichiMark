import ComposableArchitecture

@Reducer
struct EventDetail {

    @ObservableState
    struct State: Equatable {
        var selectedTab: EventDetailTab = .basic
        var basicInfoState: BasicInfoState
        var michiInfoState: MichiInfo.State
        var paymentInfoState: PaymentInfo.State
        var summaryState: Summary.State
        var routeInfoState: RouteInfo.State
    }

    // ★ ここが重要
    @CasePathable
    enum Action: Equatable {
        case backButtonTapped
        case tabSelected(EventDetailTab)

        case basicInfo(BasicInfoAction)
        case michiInfo(MichiInfo.Action)
        case paymentInfo(PaymentInfo.Action)
        case summary(Summary.Action)
        case routeInfo(RouteInfo.Action)
    }

    var body: some ReducerOf<Self> {

        Scope(
            state: \.basicInfoState,
            action: \.basicInfo
        ) {
            BasicInfoReducer()
        }

        Scope(state: \.michiInfoState, action: \.michiInfo) {
            MichiInfo()
        }

        Scope(state: \.paymentInfoState, action: \.paymentInfo) {
            PaymentInfo()
        }

        Scope(state: \.summaryState, action: \.summary) {
            Summary()
        }

        Scope(state: \.routeInfoState, action: \.routeInfo) {
            RouteInfo()
        }

        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case .backButtonTapped:
                return .none

            default:
                return .none
            }
        }
    }
}
