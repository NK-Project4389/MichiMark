import ComposableArchitecture
import Foundation

// 「画面」「遷移」
//State
//画面表示に必要な 集約 State
//子 Feature の State を 保持
//ナビゲーション状態を 保持
//Action
//View 由来の Action
//子 Feature からの Delegate
//CoreReducer への 橋渡し
//Reduce の責務
//Scope の定義
//Navigation 制御
//Delegate を Core に変換
@Reducer
struct EventDetailReducer {
    @ObservableState
    struct State{
        var core: EventDetailCoreReducer.State
    }

    enum Action {
        // CoreReducerへの橋渡し
        case core(EventDetailCoreReducer.Action)
        // EventDetail 戻るボタン
        case dismissTapped
        case delegate(Delegate)
    }
    
    enum Delegate {
        // 子Feature表示
        case openMarkDetail(MarkLinkID)
        case openLinkDetail(MarkLinkID)
        case openPaymentDetail(PaymentID)
        case addMarkOrLinkSelected(MarkOrLink)
        // MARK: 選択画面
        case selectionRequested(useCase: SelectionUseCase)
        case saved
        case dismiss
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // EventDetail 戻るボタン
            case .dismissTapped:
                return .send(.delegate(.dismiss))

            // EventDetail Delegate
            case .core(.delegate(let delegate)):
                return .send(.delegate(delegate))

            default:
                return .none
            }
        }

        Scope(state: \.core, action: \.core) {
            EventDetailCoreReducer()
        }
    }

}

//State
//👉 UI 表示用 State は持たない
//👉 「タブ」「遷移」「画面状態」を一切知らない
//Action
//ユースケース単位の命令
//意味論が UI 非依存
//Reduce
//Validation
//Repository 呼び出し
//Effect 発行
//🔑 CoreReducer は View が消えても成立する
@Reducer
struct EventDetailCoreReducer {
    // リポジトリ取得
    @Dependency(\.eventRepositoryProtocol)
    var eventRepository
    
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
    }

    enum Action {
        //EventDetail タブ選択
        case tabSelected(EventDetailTab)

        //BasicInfo アクション全般
        case basicInfo(BasicInfoReducer.Action)
        //case saveBasicInfoDraft(EventID, BasicInfoReducer.State.Draft)
        
        //MichiInfo アクション全般
        case michiInfo(MichiInfoReducer.Action)
        //PaymentInfo アクション全般
        case paymentInfo(PaymentInfoReducer.Action)
        //Overview アクション全般
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
                    
                // 保存完了時にイベント一覧へ戻る
                case .saveCompleted:
                    return .run { send in
                        await send(.delegate(.saved))  // 親に通知
                        // await dismiss()            // 正規ルートで pop（Root側で制御する）
                    }

                case let .basicInfo(.delegate(.selectionRequested(useCase))):
                    return .send(.delegate(.selectionRequested(useCase: useCase)))

                case .basicInfo:
                    return .none
                
                // MARK: MichiInfo
                case let .michiInfo(.delegate(.openMarkDetail(_, markLinkID))):
                    return .send(.delegate(.openMarkDetail(markLinkID)))

                case let .michiInfo(.delegate(.openLinkDetail(_, markLinkID))):
                    return .send(.delegate(.openLinkDetail(markLinkID)))

                case let .michiInfo(.delegate(.addMarkOrLinkSelected(type))):
                    return .send(.delegate(.addMarkOrLinkSelected(type)))

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
    }
}
