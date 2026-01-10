import ComposableArchitecture
import Foundation

@Reducer
struct EventDetailReducer {

    @ObservableState
    struct State{
        var core: EventDetailCoreReducer.State
        @Presents var destination: Destination.State?
    }

    enum Action {
        case core(EventDetailCoreReducer.Action)
        case destination(PresentationAction<Destination.Action>)
        case dismissTapped
    }
    
    enum Delegate {
        case openMarkDetail(MarkLinkID)
        case openLinkDetail(MarkLinkID)
        case openPaymentDetail(PaymentID)
        case dismiss
    }

    @Reducer
    enum Destination {
        case markDetail(MarkDetailReducer)
        case linkDetail(LinkDetailReducer)
        case paymentDetail(PaymentDetailReducer)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.core, action: \.core){
            EventDetailCoreReducer()
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

@Reducer
struct EventDetailCoreReducer {

    @ObservableState
    struct State{
        // 外部依存（識別子）
        var eventID: EventID

        //集約Projection
        var projection: EventDetailProjection
        // UI派生State
        var selectedTab: EventDetailTab = .basicInfo

        // 子Feature state
        var basicInfo: BasicInfoReducer.State
        var michiInfo: MichiInfoReducer.State
        var paymentInfo: PaymentInfoReducer.State
        var overview: OverviewReducer.State
        
        init(projection: EventDetailProjection){
            self.eventID = projection.eventId
            self.projection = projection
            
            self.basicInfo = .init(projection: projection.basicInfo, eventID: projection.eventId)
            self.michiInfo = .init(projection: projection.michiInfo, eventID: projection.eventId)
            self.paymentInfo = .init(projection: projection.paymentInfo, eventID: projection.eventId)
            self.overview = .init()
        }
//        init(eventID: EventID) {
//            self.eventID = eventID
//            self.selectedTab = .basicInfo
//            self.basicInfo = BasicInfoReducer.State(eventID: eventID)
//            self.michiInfo = MichiInfoReducer.State(eventID: eventID)
//            self.paymentInfo = PaymentInfoReducer.State(eventID: eventID)
//            self.overview = OverviewReducer.State()
//            self.destination = nil
//        }
    }

    enum Action {
        case tabSelected(EventDetailTab)

        case basicInfo(BasicInfoReducer.Action)
        //case saveBasicInfoDraft(EventID, BasicInfoReducer.State.Draft)
        
        case michiInfo(MichiInfoReducer.Action)
        case paymentInfo(PaymentInfoReducer.Action)
        case overview(OverviewReducer.Action)
        // ★ Root に通知するための Action
        case delegate(EventDetailReducer.Delegate)
    }

    var body: some ReducerOf<Self> {
        CombineReducers{
//            Scope(state: \.basicInfo, action: \.basicInfo) { BasicInfoReducer() }
//            Scope(state: \.michiInfo, action: \.michiInfo) { MichiInfoReducer() }
//            Scope(state: \.paymentInfo, action: \.paymentInfo) { PaymentInfoReducer() }
//            Scope(state: \.overview, action: \.overview) { OverviewReducer() }
            
//            Reduce { _, _ in .none }
            Reduce { state, action in
                switch action {
                case let .tabSelected(tab):
                    state.selectedTab = tab
                    return .none

//                case .dismissTapped:
//                    return .send(.delegate(.dismiss))
                    
                case let .basicInfo(.delegate(.saveDraft(eventID, draft))):
//                    return .send(
//                        .saveBasicInfoDraft(eventID, draft)
//                    )
                    return .none
                
//                case let .saveBasicInfoDraft(eventID, draft):
//                    //現時点では受け取るだけ
//                    //BasicInfo Draftの保存を後で実装
//                    return .none
                
                case .basicInfo:
                    return .none
                

                case .michiInfo, .paymentInfo, .overview:
                    return .none
                
                case .delegate:
                    return .none
                
                
                }
            }
//            Reduce { state, action in
//                switch action {
//                    
//                case let .tabSelected(tab):
//                    state.selectedTab = tab
//                    return .none
//                    

//                    
//                    //BasicInfo → EventDetail（Navigation）
//                case let .basicInfo(.delegate(.saveDraft(eventID, draft))):
//                    return .none
//                    
//                case let .applyProjection(projection):
//                    //                state.projection = projection
//                    //
//                    //                // 子 Feature へ再注入
//                    //                state.basicInfo.projection = projection.basicInfo
//                    //                state.basicInfo.draft = .init(
//                    //                    eventName: projection.basicInfo.eventName,
//                    //                    eventDate: projection.basicInfo.eventDate,
//                    //                    kmPerGas: projection.basicInfo.rawKmPerGas ?? "",
//                    //                    pricePerGas: projection.basicInfo.rawPricePerGas ?? ""
//                    //                )
//                    //
//                    //                state.michiInfo.projection = projection.michiInfo
//                    //                state.paymentInfo.projection = projection.paymentInfo
//                    //                state.overview.projection = projection.overview
//                    
//                    return .none
//                    
//                    // MichiInfo → EventDetail（Navigation）
//                case let .michiInfo(.delegate(delegate)):
//                    switch delegate {
//                        
//                    case let .openMarkDetail(eventID, markLinkID):
//                        return .send(.delegate(.openMarkDetail(markLinkID)))
//                        
//                    case let .openLinkDetail(eventID, markLinkID):
//                        return .send(.delegate(.openLinkDetail(markLinkID)))
//                        
//                    case .addMark(eventID):
//                        let newID = MarkLinkID()
//                        return .send(.delegate(.openMarkDetail(newID)))
//                    }
//                    
//                    // PaymentInfo > EventDetail (Navigation)
//                    //            case let .paymentInfo(.paymentTapped(PaymentID)):
//                    //                return .send(.delegate(.openPaymentDetail(PaymentID)))
//                case let .paymentInfo(.paymentTapped(paymentID)):
//                    return .send(.delegate(.openPaymentDetail(paymentID)))
//                    
//                    
//                case .paymentInfo(.addPaymentTapped):
//                    //                let newID = UUID()
//                    //                return .send(.delegate(.openPaymentDetail(newID)))
//                    let newID = PaymentID()
//                    return .send(.delegate(.openPaymentDetail(newID)))
//                    
//                    // ✅ 追加（これがないとエラー）
//                case .michiInfo(.appeared):
//                    return .none
//                case .delegate:
//                    return .none
//                    // 子 Feature からの Action はここで握りつぶす
//                case .basicInfo,
//                        .paymentInfo,
//                        .michiInfo,
//                        .overview:
//                    return .none
//                    
//                case .destination:
//                    return .none
//                }
//            }
            
        }
    }
}
extension EventDetailReducer.State {
    init(projection: EventDetailProjection) {
        self.core = EventDetailCoreReducer.State(projection: projection)
        self.destination = nil
    }
}
