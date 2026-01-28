import ComposableArchitecture
import Foundation

@Reducer
struct EventDetailReducer {
    @Dependency(\.dismiss) var dismiss

    @ObservableState
    struct State{
        var core: EventDetailCoreReducer.State
        @Presents var destination: Destination.State?
    }

    enum Action {
        case core(EventDetailCoreReducer.Action)
        case destination(PresentationAction<Destination.Action>)
        case dismissTapped
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case openMarkDetail(MarkLinkID)
        case openLinkDetail(MarkLinkID)
        case openPaymentDetail(PaymentID)
        // MARK: 選択画面
        case openTransSelect
        case openTotalMemberSelect(ids: Set<MemberID>)
        case openTagSelect
        case openGasPayMemberSelect(ids: Set<MemberID>)
        case saved
        case dismiss
    }

    @Reducer
    enum Destination {
        case markDetail(MarkDetailReducer)
        case linkDetail(LinkDetailReducer)
        case paymentDetail(PaymentDetailReducer)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
//            case .dismissTapped:
//                return .send(.core(.delegate(.dismiss)))
            case .dismissTapped:
                return .run { _ in
                    await dismiss()
                }

                
            case .core(.delegate(let delegate)):
                return .send(.delegate(delegate))

            default:
                return .none
            }
        }

        Scope(state: \.core, action: \.core) {
            EventDetailCoreReducer()
        }
        .ifLet(\.$destination, action: \.destination)
    }

}

@Reducer
struct EventDetailCoreReducer {
    @Dependency(\.eventRepositoryProtocol)
    var eventRepository

    @Dependency(\.dismiss) var dismiss
    
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
        case saveCompleted
        case delegate(EventDetailReducer.Delegate)
    }

    var body: some ReducerOf<Self> {
        CombineReducers{
            Scope(state: \.basicInfo, action: \.basicInfo) { BasicInfoReducer() }
            Scope(state: \.michiInfo, action: \.michiInfo) { MichiInfoReducer() }
//            Scope(state: \.paymentInfo, action: \.paymentInfo) { PaymentInfoReducer() }
//            Scope(state: \.overview, action: \.overview) { OverviewReducer() }
            
            Reduce { state, action in
                switch action {
                case let .tabSelected(tab):
                    state.selectedTab = tab
                    return .none
                    
                // MARK: BasicInfo
                //保存ボタン押下
                case let .basicInfo(.delegate(.saveDraft(eventID, draft))):
                    return .run { send in
                        let current: EventDomain
                        do {
                            current = try await eventRepository.fetch(id: eventID)
                        } catch RepositoryError.notFound {
                            current = EventDomain(id: eventID, eventName: "")
                        }

                        let updated = current.updatingBasicInfo(from: draft)
                        try await eventRepository.save(updated)

                        await send(.saveCompleted)   // ★ Effect 完了通知
                    } catch: { error, _ in
                        print("Save failed:", error)
                    }
                    
                case .saveCompleted:
                    return .run { send in
                        await send(.delegate(.saved))  // 親に通知
                        await dismiss()                // 正規ルートで pop
                    }

                //交通手段ボタン押下
                case .basicInfo(.transTapped):
                    return .send(.delegate(.openTransSelect))
                //メンバーボタン、支払い者ボタン押下
                case let .basicInfo(.delegate(.membersSelectionRequested(ids, useCase))):
                    switch useCase {
                    case .totalMembers:
                        return .send(.delegate(.openTotalMemberSelect(ids: ids)))
                    case .gasPayer:
                        return .send(.delegate(.openGasPayMemberSelect(ids: ids)))
                    default:
                        return .none
                    }
                //タグボタン押下
                case .basicInfo(.tagsTapped):
                    return .send(.delegate(.openTagSelect))
                
                case .basicInfo:
                    return .none
                
                // MARK: MichiInfo
                case let .michiInfo(.delegate(.openMarkDetail(_, markLinkID))):
                    return .send(.delegate(.openMarkDetail(markLinkID)))

                case let .michiInfo(.delegate(.openLinkDetail(_, markLinkID))):
                    return .send(.delegate(.openLinkDetail(markLinkID)))

                case .michiInfo(.delegate(.addMark(_))):
                    // 今回はまだ遷移しなくてOK
                    return .none

                // MARK: Other
                case .michiInfo, .paymentInfo, .overview:
                    return .none
                
                // その他
                default:
                    return .none
                
                
                }
            }
            
        }
    }
}
extension EventDetailReducer.State {
    init(projection: EventDetailProjection) {
        self.core = EventDetailCoreReducer.State(projection: projection)
        self.destination = nil
    }
}
