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
        @Presents var destination: Destination.State?
    }

    enum Action {
        case core(EventDetailCoreReducer.Action)
        case destination(PresentationAction<Destination.Action>)
        case dismissTapped
        case markDetailMembersSelected(Set<MemberID>, [MemberID: String], MemberSelectionUseCase)
        case markDetailActionsSelected(Set<ActionID>, [ActionID: String], ActionSelectionUseCase)
        case transSelectionResultReceived(TransID?, String?)
        case transSelectionCancelled
        case totalMembersSelectionResultReceived(Set<MemberID>, [MemberID: String])
        case gasPayMemberSelectionResultReceived(MemberID?, String?)
        case tagSelectionResultReceived(Set<TagID>, [TagID: String])
        case membersSelectionCancelled
        case tagSelectionCancelled
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case openMarkDetail(MarkLinkID)
        case openLinkDetail(MarkLinkID)
        case openPaymentDetail(PaymentID)
        // MARK: 選択画面
        case transSelectionRequested(
            context: SelectionContext<TransID, EventDetailReducer.Action>,
            items: IdentifiedArrayOf<SelectionFeature<TransID>.Item>
        )
        case totalMembersSelectionRequested(
            context: SelectionContext<MemberID, EventDetailReducer.Action>,
            items: IdentifiedArrayOf<SelectionFeature<MemberID>.Item>
        )
        case tagSelectionRequested(
            context: SelectionContext<TagID, EventDetailReducer.Action>,
            items: IdentifiedArrayOf<SelectionFeature<TagID>.Item>
        )
        case gasPayMemberSelectionRequested(
            context: SelectionContext<MemberID, EventDetailReducer.Action>,
            items: IdentifiedArrayOf<SelectionFeature<MemberID>.Item>
        )
        case openMarkDetailMemberSelect(ids: Set<MemberID>, mode: MemberSelectReducer.SelectionMode)
        case openMarkDetailActionSelect(ids: Set<ActionID>)
        case openLinkDetailMemberSelect(ids: Set<MemberID>)
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
            // EventDetail 戻るボタン
            case .dismissTapped:
                return .send(.delegate(.dismiss))

            // EventDetail Delegate
            case .core(.delegate(let delegate)):
                return .send(.delegate(delegate))
            
            // MichiInfo マーク詳細
            case let .delegate(.openMarkDetail(markLinkID)):
                guard let itemProjection = state.core.projection.michiInfo.items
                    .first(where: { $0.id == markLinkID })
                else { return .none }

                let markDetailDraft = MarkDetailDraft(projection: itemProjection)
                state.destination = .markDetail(
                    MarkDetailReducer.State(
                        projection: itemProjection,
                        draft: markDetailDraft,
                        eventID: state.core.eventID,
                        markLinkID: markLinkID
                    )
                )
                return .none

            // MichiInfo リンク詳細
            case let .delegate(.openLinkDetail(markLinkID)):
                guard let itemProjection = state.core.projection.michiInfo.items
                    .first(where: { $0.id == markLinkID })
                else { return .none }

                state.destination = .linkDetail(
                    LinkDetailReducer.State(
                        projection: itemProjection,
                        eventID: state.core.eventID,
                        markLinkID: markLinkID
                    )
                )
                return .none

            // MichiInfo MarkDetail 反映ボタン
            case let .destination(.presented(.markDetail(.delegate(.applied(markLinkID, draft))))):
                state.destination = nil
                return .send(
                    .core(.michiInfo(.markDetailDraftApplied(markLinkID, draft)))
                )

            // MichiInfo MarkDetail メンバー選択　受信
            case let .destination(.presented(.markDetail(.delegate(.membersSelectionRequested(ids, _, mode))))):
                return .send(.delegate(.openMarkDetailMemberSelect(ids: ids, mode: mode)))

            // MichiInfo MarkDetail 行動選択
            case let .destination(.presented(.markDetail(.delegate(.actionsSelectionRequested(ids, _))))):
                return .send(.delegate(.openMarkDetailActionSelect(ids: ids)))

            // MichiInfo MarkDetail メンバー選択　上位通知
            case let .markDetailMembersSelected(ids, names, useCase):
                guard useCase == .markMembers else { return .none }
                guard case var .markDetail(markDetailState) = state.destination
                else { return .none }
                markDetailState.draft.selectedMemberIDs = ids
                markDetailState.draft.selectedMemberNames = names
                state.destination = .markDetail(markDetailState)
                return .none

            // MichiInfo MarkDetail 行動選択　上位通知
            case let .markDetailActionsSelected(ids, names, useCase):
                guard useCase == .markActions else { return .none }
                guard case var .markDetail(markDetailState) = state.destination
                else { return .none }
                markDetailState.draft.selectedActionIDs = ids
                markDetailState.draft.selectedActionNames = names
                state.destination = .markDetail(markDetailState)
                return .none
                
            // PaymentInfo 支払詳細
            case let .delegate(.openPaymentDetail(paymentID)):
                guard let paymentProjection = state.core.projection.paymentInfo.items
                    .first(where: { $0.id == paymentID })
                else { return .none }

                state.destination = .paymentDetail(
                    PaymentDetailReducer.State(
                        projection: paymentProjection,
                        eventID: state.core.eventID,
                        paymentID: paymentID
                    )
                )
                return .none
                
            // Trans 選択結果（Draft 更新）
            case let .transSelectionResultReceived(id, name):
                state.core.basicInfo.draft.selectedTransID = id
                state.core.basicInfo.draft.selectedTransName = name
                return .none

            case .transSelectionCancelled:
                return .none
                
            // Member / Tag 選択結果（Draft 更新）
            case let .totalMembersSelectionResultReceived(ids, names):
                state.core.basicInfo.draft.selectedMemberIDs = ids
                state.core.basicInfo.draft.selectedMemberNames = names
                return .none
                
            case let .gasPayMemberSelectionResultReceived(id, name):
                state.core.basicInfo.draft.selectedPayMemberID = id
                state.core.basicInfo.draft.selectedPayMemberName = name
                return .none
                
            case let .tagSelectionResultReceived(ids, names):
                state.core.basicInfo.draft.selectedTagIDs = ids
                state.core.basicInfo.draft.selectedTagNames = names
                return .none
                
            case .membersSelectionCancelled, .tagSelectionCancelled:
                return .none

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
    @Dependency(\.eventRepositoryProtocol)
    var eventRepository
    @Dependency(\.transRepository)
    var transRepository
    @Dependency(\.memberRepository)
    var memberRepository
    @Dependency(\.tagRepository)
    var tagRepository
    
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
                        // await dismiss()            // 正規ルートで pop（Root側で制御する）
                    }

                //交通手段ボタン押下
                case .basicInfo(.transTapped):
                    let draft = state.basicInfo.draft
                    return .run { [draft] send in
                        do {
                            let domains = try await transRepository.fetchAll()
                            let projections = TransProjectionAdapter()
                                .adaptList(transes: domains)
                                .filter { $0.isVisible }

                            let items = IdentifiedArrayOf<SelectionFeature<TransID>.Item>(
                                uniqueElements: projections.map { projection in
                                    let subtitleParts = [
                                        projection.displayKmPerGas.isEmpty ? nil : "燃費 \(projection.displayKmPerGas)",
                                        projection.displayMeterValue.isEmpty ? nil : "メーター \(projection.displayMeterValue)"
                                    ].compactMap { $0 }
                                    let subtitle = subtitleParts.isEmpty
                                        ? nil
                                        : subtitleParts.joined(separator: " / ")

                                    return SelectionFeature<TransID>.Item(
                                        id: projection.id,
                                        title: projection.transName,
                                        subtitle: subtitle
                                    )
                                }
                            )
                            
                            let nameMap = Dictionary(
                                uniqueKeysWithValues: projections.map { ($0.id, $0.transName) }
                            )

                            let context = draft.makeTransSelectionContext(
                                onSelected: { ids in
                                    let id = ids.first
                                    let name = id.flatMap { nameMap[$0] }
                                    return .transSelectionResultReceived(id, name)
                                },
                                onCancelled: {
                                    .transSelectionCancelled
                                }
                            )

                            await send(.delegate(.transSelectionRequested(context: context, items: items)))
                        } catch {
                            // エラー時は何もしない（表示側の責務に委譲）
                        }
                    }
                //メンバーボタン、支払い者ボタン押下
                case let .basicInfo(.delegate(.membersSelectionRequested(ids, useCase))):
                    let draft = state.basicInfo.draft
                    return .run { [draft, ids, useCase] send in
                        do {
                            let domains = try await memberRepository.fetchAll()
                            let projections = MemberProjectionAdapter()
                                .adaptList(members: domains)
                                .filter { $0.isVisible }

                            let items = IdentifiedArrayOf<SelectionFeature<MemberID>.Item>(
                                uniqueElements: projections.map { projection in
                                    let subtitle = projection.mailAddress?.isEmpty == false
                                        ? projection.mailAddress
                                        : nil
                                    return SelectionFeature<MemberID>.Item(
                                        id: projection.id,
                                        title: projection.memberName,
                                        subtitle: subtitle
                                    )
                                }
                            )

                            let nameMap = Dictionary(
                                uniqueKeysWithValues: projections.map { ($0.id, $0.memberName) }
                            )

                            switch useCase {
                            case .totalMembers:
                                let context = draft.makeMemberSelectionContext(
                                    onSelected: { selectedIDs in
                                        let names = Dictionary(
                                            uniqueKeysWithValues: selectedIDs.compactMap { id in
                                                nameMap[id].map { (id, $0) }
                                            }
                                        )
                                        return .totalMembersSelectionResultReceived(selectedIDs, names)
                                    },
                                    onCancelled: { .membersSelectionCancelled }
                                )
                                await send(.delegate(.totalMembersSelectionRequested(context: context, items: items)))

                            case .gasPayer:
                                let context = draft.makePayMemberSelectionContext(
                                    onSelected: { selectedIDs in
                                        let id = selectedIDs.first
                                        let name = id.flatMap { nameMap[$0] }
                                        return .gasPayMemberSelectionResultReceived(id, name)
                                    },
                                    onCancelled: { .membersSelectionCancelled }
                                )
                                await send(.delegate(.gasPayMemberSelectionRequested(context: context, items: items)))

                            default:
                                return
                            }
                        } catch {
                            // エラー時は何もしない（表示側の責務に委譲）
                        }
                    }
                //タグボタン押下
                case .basicInfo(.tagsTapped):
                    let draft = state.basicInfo.draft
                    return .run { [draft] send in
                        do {
                            let domains = try await tagRepository.fetchAll()
                            let projections = TagProjectionAdapter()
                                .adaptList(tags: domains)
                                .filter { $0.isVisible }

                            let items = IdentifiedArrayOf<SelectionFeature<TagID>.Item>(
                                uniqueElements: projections.map { projection in
                                    SelectionFeature<TagID>.Item(
                                        id: projection.id,
                                        title: projection.tagName,
                                        subtitle: nil
                                    )
                                }
                            )

                            let nameMap = Dictionary(
                                uniqueKeysWithValues: projections.map { ($0.id, $0.tagName) }
                            )

                            let context = draft.makeTagSelectionContext(
                                onSelected: { selectedIDs in
                                    let names = Dictionary(
                                        uniqueKeysWithValues: selectedIDs.compactMap { id in
                                            nameMap[id].map { (id, $0) }
                                        }
                                    )
                                    return .tagSelectionResultReceived(selectedIDs, names)
                                },
                                onCancelled: { .tagSelectionCancelled }
                            )

                            await send(.delegate(.tagSelectionRequested(context: context, items: items)))
                        } catch {
                            // エラー時は何もしない（表示側の責務に委譲）
                        }
                    }
                
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
    }
}
