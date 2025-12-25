import ComposableArchitecture
import Foundation

@Reducer
struct EventDetailReducer {

    @ObservableState
    struct State: Equatable {
        // 外部依存（識別子）
        var eventID: EventID

        // UI派生State
        var selectedTab: EventDetailTab

        // 子Feature state
        var basicInfo = BasicInfoReducer.State(eventID: UUID())
        var michiInfo = MichiInfoReducer.State(eventID: UUID())
        var paymentInfo = PaymentInfoReducer.State(eventID: UUID())
        var overview = OverviewReducer.State()

        // Mark/Link の遷移（EventDetail が管理）
        @Presents var destination: Destination.State?

        init(eventID: EventID) {
            self.eventID = eventID
            self.selectedTab = .basicInfo
            self.basicInfo = BasicInfoReducer.State(eventID: eventID)
            self.michiInfo = MichiInfoReducer.State(eventID: eventID)
            self.paymentInfo = PaymentInfoReducer.State(eventID: eventID)
            self.overview = OverviewReducer.State()
            self.destination = nil
        }
    }

    enum Action {
        case tabSelected(EventDetailTab)

        case basicInfo(BasicInfoReducer.Action)
        case michiInfo(MichiInfoReducer.Action)
        case paymentInfo(PaymentInfoReducer.Action)
        case overview(OverviewReducer.Action)
        // ★ Root に通知するための Action
        case delegate(Delegate)

        enum Delegate {
            case openMarkDetail(MarkLinkID)
            case openLinkDetail(MarkLinkID)
            case openPaymentDetail(PaymentID)
            case dismiss
        }
        // View 側の戻るボタン（既存Viewに合わせて用意）
        case dismissTapped

        case destination(PresentationAction<Destination.Action>)
    }

    @Reducer(state: .equatable)
    enum Destination {
        case markDetail(MarkDetailReducer)
        case linkDetail(LinkDetailReducer)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.basicInfo, action: \.basicInfo) { BasicInfoReducer() }
        Scope(state: \.michiInfo, action: \.michiInfo) { MichiInfoReducer() }
        Scope(state: \.paymentInfo, action: \.paymentInfo) { PaymentInfoReducer() }
        Scope(state: \.overview, action: \.overview) { OverviewReducer() }

        Reduce { state, action in
            switch action {

            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case .dismissTapped:
                return .send(.delegate(.dismiss))

            // MichiInfo → EventDetail（Navigation）
            case let .michiInfo(.markTapped(markLinkID)):
                return .send(.delegate(.openMarkDetail(markLinkID)))

            case let .michiInfo(.linkTapped(markLinkID)):
                return .send(.delegate(.openLinkDetail(markLinkID)))

            case .michiInfo(.addMarkTapped):
                let newID = UUID()
                return .send(.delegate(.openMarkDetail(newID)))
            
            // PaymentInfo > EventDetail (Navigation)
            case let .paymentInfo(.paymentTapped(PaymentID)):
                return .send(.delegate(.openPaymentDetail(PaymentID)))

            case .paymentInfo(.addPaymentTapped):
                let newID = UUID()
                return .send(.delegate(.openPaymentDetail(newID)))
                
            // ✅ 追加（これがないとエラー）
            case .michiInfo(.appeared):
                return .none
            case .delegate:
                return .none
            // 子 Feature からの Action はここで握りつぶす
            case .basicInfo,
                 .paymentInfo,
                 .overview:
                return .none

            case .destination:
                return .none
            }
        }

        .ifLet(\.$destination, action: \.destination)
    }
}
