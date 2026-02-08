import ComposableArchitecture
import Foundation

@Reducer
struct RootReducer {

    enum AppMode: Equatable {
        case personal
        case business
    }

    enum Screen: Equatable {
        case eventList
        case eventDetail(EventID)
        case settings
    }

    enum MemberSelectionSource: Equatable {
        case eventDetail(StackElementID)
        case markDetail(StackElementID)
        case linkDetail(StackElementID)
    }

    enum ActionSelectionSource: Equatable {
        case eventDetail(StackElementID)
        case markDetail(StackElementID)
        case linkDetail(StackElementID)
    }

    @ObservableState
    struct State {
        // UI派生State（グローバル）
        var currentScreen: Screen = .eventList

        // NavigationStack
        var path = StackState<Path.State>()

        // 子Feature（常駐）
        var eventList = EventListReducer.State()

        // SelectionFeature の中継用（意味解釈はしない）
        // TODO: SelectionContext が増えた場合は enum + associated value への昇格を検討する
        var selectionContextTrans: SelectionContext<TransID, EventDetailReducer.Action>?
        var selectionSourceElementIDTrans: StackElementID?
        var selectionContextMember: SelectionContext<MemberID, EventDetailReducer.Action>?
        var selectionSourceElementIDMember: MemberSelectionSource?
        var selectionContextTag: SelectionContext<TagID, EventDetailReducer.Action>?
        var selectionSourceElementIDTag: StackElementID?
        var selectionContextAction: SelectionContext<ActionID, Action>?
        var selectionContextActionEventDetail: SelectionContext<ActionID, EventDetailReducer.Action>?
        var selectionSourceElementIDAction: ActionSelectionSource?

        // EventDetail から開いた Mark/Link の追跡
        var markDetailSourceByElementID: [StackElementID: StackElementID] = [:]
        var linkDetailSourceByElementID: [StackElementID: StackElementID] = [:]

        // 外部依存State
        var appMode: AppMode = .personal
    }

    enum Action {
        case eventList(EventListReducer.Action)
        case path(StackAction<Path.State, Path.Action>)
        case presentTransSelection(SelectionContext<TransID, EventDetailReducer.Action>)
        case presentMemberSelection(SelectionContext<MemberID, EventDetailReducer.Action>)
        case presentTagSelection(SelectionContext<TagID, EventDetailReducer.Action>)
        case presentActionSelection(SelectionContext<ActionID, Action>)
    }
    
    @Dependency(\.eventRepositoryProtocol) var eventRepositoryProtocol

    @Reducer
    enum Path {
        //設定系
        case settings(SettingsReducer)
        case transSetting(TransSettingReducer)
        case memberSetting(MemberSettingReducer)
        case tagSetting(TagSettingReducer)
        case actionSetting(ActionSettingReducer)
        //イベント詳細
        case eventDetail(EventDetailReducer)
        case markDetail(MarkDetailReducer)
        case linkDetail(LinkDetailReducer)
        case paymentDetail(PaymentDetailReducer)
        //選択
        case transSelect(TransSelectReducer)
        case memberSelect(MemberSelectReducer)
        case tagSelect(TagSelectReducer)
        case actionSelect(ActionSelectReducer)
        case transSelection(SelectionFeature<TransID>)
        case memberSelection(SelectionFeature<MemberID>)
        case tagSelection(SelectionFeature<TagID>)
        case actionSelection(SelectionFeature<ActionID>)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.eventList, action: \.eventList) { EventListReducer() }

        //一時的なダミーProjection
        Reduce { state, action in
            switch action {

            // ============================
            // MARK: EventList → Root（Navigation）
            // ============================
            //EventList側へ処理へ委譲
            case let .eventList(.eventTapped(eventID)):
                let projection = EventDetailProjection.empty(eventID: eventID)
                state.path.append(
                    .eventDetail(
                        EventDetailReducer.State(projection: projection)
                    )
                )
                return .none
//                将来的にCoreDomainから呼び出す
//                return .run { [eventID] send in
//                    let event = try await eventRepositoryProtocol.fetch(id: eventID)
//
//                    let projection = EventDetailProjectionAdapter()
//                        .adapt(event: event)
//
//                    await send(
//                        .path(
//                            .push(
//                                id: StackElementID(),
//                                state: .eventDetail(
//                                    EventDetailReducer.State(projection: projection)
//                                )
//                            )
//                        )
//                    )
//                }
                
            case .eventList(.addButtonTapped):
                let newEventID = EventID()
                let projection = EventDetailProjection.empty(eventID: newEventID)

                state.path.append(
                    .eventDetail(
                        EventDetailReducer.State(projection: projection)
                    )
                )
                return .none


                //EventList側へ処理へ委譲
            case .eventList(.settingsButtonTapped):
                state.path.append(.settings(SettingsReducer.State()))
                return .none

                //EventList側へ処理へ委譲
            case .eventList(.appeared),
                 .eventList(.deleteResponse):
                return .none

            // ============================
            // MARK: SelectionFeature (汎用)
            // ============================

            case let .presentTransSelection(context):
                state.selectionContextTrans = context
                state.selectionSourceElementIDTrans = nil
                state.path.append(
                    .transSelection(
                        SelectionFeature<TransID>.State(
                            // TODO: 呼び出し元から items を受け取れるようにする
                            items: [],
                            selected: context.preselected,
                            allowsMultipleSelection: context.allowsMultipleSelection
                        )
                    )
                )
                return .none
                
            case let .presentMemberSelection(context):
                state.selectionContextMember = context
                state.selectionSourceElementIDMember = nil
                state.path.append(
                    .memberSelection(
                        SelectionFeature<MemberID>.State(
                            items: [],
                            selected: context.preselected,
                            allowsMultipleSelection: context.allowsMultipleSelection
                        )
                    )
                )
                return .none
                
            case let .presentTagSelection(context):
                state.selectionContextTag = context
                state.selectionSourceElementIDTag = nil
                state.path.append(
                    .tagSelection(
                        SelectionFeature<TagID>.State(
                            items: [],
                            selected: context.preselected,
                            allowsMultipleSelection: context.allowsMultipleSelection
                        )
                    )
                )
                return .none
                
            case let .presentActionSelection(context):
                state.selectionContextAction = context
                state.path.append(
                    .actionSelection(
                        SelectionFeature<ActionID>.State(
                            items: [],
                            selected: context.preselected,
                            allowsMultipleSelection: context.allowsMultipleSelection
                        )
                    )
                )
                return .none

            case let .path(
                .element(id: elementID, action: .transSelection(.delegate(.selected(ids))))
            ):
                guard let context = state.selectionContextTrans else { return .none }
                let sourceID = state.selectionSourceElementIDTrans
                state.selectionContextTrans = nil
                state.selectionSourceElementIDTrans = nil
                state.path.pop(from: elementID)
                // Root は ID の意味解釈をせず、SelectionContext のクロージャへ中継するだけ
                let eventDetailAction = context.onSelected(ids)
                guard let sourceID else { return .none }
                return .send(
                    .path(
                        .element(
                            id: sourceID,
                            action: .eventDetail(eventDetailAction)
                        )
                    )
                )

            case let .path(
                .element(id: elementID, action: .transSelection(.delegate(.cancelled)))
            ):
                guard let context = state.selectionContextTrans else { return .none }
                let sourceID = state.selectionSourceElementIDTrans
                state.selectionContextTrans = nil
                state.selectionSourceElementIDTrans = nil
                state.path.pop(from: elementID)
                let eventDetailAction = context.onCancelled()
                guard let sourceID else { return .none }
                return .send(
                    .path(
                        .element(
                            id: sourceID,
                            action: .eventDetail(eventDetailAction)
                        )
                    )
                )
                
            case let .path(
                .element(id: elementID, action: .memberSelection(.delegate(.selected(ids))))
            ):
                guard let context = state.selectionContextMember else { return .none }
                let sourceID = state.selectionSourceElementIDMember
                let selectionItems: IdentifiedArrayOf<SelectionFeature<MemberID>.Item>
                if case let .memberSelection(selectionState)? = state.path[id: elementID] {
                    selectionItems = selectionState.items
                } else {
                    selectionItems = []
                }

                state.selectionContextMember = nil
                state.selectionSourceElementIDMember = nil
                state.path.pop(from: elementID)

                let names = Dictionary(
                    uniqueKeysWithValues: selectionItems
                        .filter { ids.contains($0.id) }
                        .map { ($0.id, $0.title) }
                )

                var effects: [Effect<Action>] = []
                let eventDetailAction = context.onSelected(ids)

                guard let sourceID else { return .none }
                switch sourceID {
                case let .eventDetail(eventDetailID):
                    effects.append(
                        .send(
                            .path(
                                .element(
                                    id: eventDetailID,
                                    action: .eventDetail(eventDetailAction)
                                )
                            )
                        )
                    )
                case let .markDetail(markDetailID):
                    if let eventDetailID = state.markDetailSourceByElementID[markDetailID] {
                        effects.append(
                            .send(
                                .path(
                                    .element(
                                        id: eventDetailID,
                                        action: .eventDetail(eventDetailAction)
                                    )
                                )
                            )
                        )
                    }
                    effects.append(
                        .send(
                            .path(
                                .element(
                                    id: markDetailID,
                                    action: .markDetail(.memberSelectionResultReceived(ids, names))
                                )
                            )
                        )
                    )
                case let .linkDetail(linkDetailID):
                    if let eventDetailID = state.linkDetailSourceByElementID[linkDetailID] {
                        effects.append(
                            .send(
                                .path(
                                    .element(
                                        id: eventDetailID,
                                        action: .eventDetail(eventDetailAction)
                                    )
                                )
                            )
                        )
                    }
                    effects.append(
                        .send(
                            .path(
                                .element(
                                    id: linkDetailID,
                                    action: .linkDetail(.memberSelectionResultReceived(ids, names))
                                )
                            )
                        )
                    )
                }

                return .merge(effects)
                
            case let .path(
                .element(id: elementID, action: .memberSelection(.delegate(.cancelled)))
            ):
                guard let context = state.selectionContextMember else { return .none }
                let sourceID = state.selectionSourceElementIDMember
                state.selectionContextMember = nil
                state.selectionSourceElementIDMember = nil
                state.path.pop(from: elementID)
                let eventDetailAction = context.onCancelled()
                guard let sourceID else { return .none }
                switch sourceID {
                case let .eventDetail(eventDetailID):
                    return .send(
                        .path(
                            .element(
                                id: eventDetailID,
                                action: .eventDetail(eventDetailAction)
                            )
                        )
                    )
                case let .markDetail(markDetailID):
                    guard let eventDetailID = state.markDetailSourceByElementID[markDetailID] else {
                        return .none
                    }
                    return .send(
                        .path(
                            .element(
                                id: eventDetailID,
                                action: .eventDetail(eventDetailAction)
                            )
                        )
                    )
                case let .linkDetail(linkDetailID):
                    guard let eventDetailID = state.linkDetailSourceByElementID[linkDetailID] else {
                        return .none
                    }
                    return .send(
                        .path(
                            .element(
                                id: eventDetailID,
                                action: .eventDetail(eventDetailAction)
                            )
                        )
                    )
                }
                
            case let .path(
                .element(id: elementID, action: .tagSelection(.delegate(.selected(ids))))
            ):
                guard let context = state.selectionContextTag else { return .none }
                let sourceID = state.selectionSourceElementIDTag
                state.selectionContextTag = nil
                state.selectionSourceElementIDTag = nil
                state.path.pop(from: elementID)
                // Root は ID の意味解釈をせず、SelectionContext のクロージャへ中継するだけ
                let eventDetailAction = context.onSelected(ids)
                guard let sourceID else { return .none }
                return .send(
                    .path(
                        .element(
                            id: sourceID,
                            action: .eventDetail(eventDetailAction)
                        )
                    )
                )
                
            case let .path(
                .element(id: elementID, action: .tagSelection(.delegate(.cancelled)))
            ):
                guard let context = state.selectionContextTag else { return .none }
                let sourceID = state.selectionSourceElementIDTag
                state.selectionContextTag = nil
                state.selectionSourceElementIDTag = nil
                state.path.pop(from: elementID)
                let eventDetailAction = context.onCancelled()
                guard let sourceID else { return .none }
                return .send(
                    .path(
                        .element(
                            id: sourceID,
                            action: .eventDetail(eventDetailAction)
                        )
                    )
                )
                
            case let .path(
                .element(id: elementID, action: .actionSelection(.delegate(.selected(ids))))
            ):
                if let context = state.selectionContextActionEventDetail {
                    let sourceID = state.selectionSourceElementIDAction
                    let selectionItems: IdentifiedArrayOf<SelectionFeature<ActionID>.Item>
                    if case let .actionSelection(selectionState)? = state.path[id: elementID] {
                        selectionItems = selectionState.items
                    } else {
                        selectionItems = []
                    }

                    state.selectionContextActionEventDetail = nil
                    state.selectionSourceElementIDAction = nil
                    state.path.pop(from: elementID)

                    let names = Dictionary(
                        uniqueKeysWithValues: selectionItems
                            .filter { ids.contains($0.id) }
                            .map { ($0.id, $0.title) }
                    )

                    var effects: [Effect<Action>] = []
                    let eventDetailAction = context.onSelected(ids)
                    guard let sourceID else { return .none }
                    switch sourceID {
                    case let .eventDetail(eventDetailID):
                        effects.append(
                            .send(
                                .path(
                                    .element(
                                        id: eventDetailID,
                                        action: .eventDetail(eventDetailAction)
                                    )
                                )
                            )
                        )
                    case let .markDetail(markDetailID):
                        if let eventDetailID = state.markDetailSourceByElementID[markDetailID] {
                            effects.append(
                                .send(
                                    .path(
                                        .element(
                                            id: eventDetailID,
                                            action: .eventDetail(eventDetailAction)
                                        )
                                    )
                                )
                            )
                        }
                        effects.append(
                            .send(
                                .path(
                                    .element(
                                        id: markDetailID,
                                        action: .markDetail(.actionSelectionResultReceived(ids, names))
                                    )
                                )
                            )
                        )
                    case let .linkDetail(linkDetailID):
                        if let eventDetailID = state.linkDetailSourceByElementID[linkDetailID] {
                            effects.append(
                                .send(
                                    .path(
                                        .element(
                                            id: eventDetailID,
                                            action: .eventDetail(eventDetailAction)
                                        )
                                    )
                                )
                            )
                        }
                        effects.append(
                            .send(
                                .path(
                                    .element(
                                        id: linkDetailID,
                                        action: .linkDetail(.actionSelectionResultReceived(ids, names))
                                    )
                                )
                            )
                        )
                    }

                    return .merge(effects)
                }
                guard let context = state.selectionContextAction else { return .none }
                state.selectionContextAction = nil
                state.path.pop(from: elementID)
                // Root は ID の意味解釈をせず、SelectionContext のクロージャへ中継するだけ
                return .send(context.onSelected(ids))
                
            case let .path(
                .element(id: elementID, action: .actionSelection(.delegate(.cancelled)))
            ):
                if let context = state.selectionContextActionEventDetail {
                    let sourceID = state.selectionSourceElementIDAction
                    state.selectionContextActionEventDetail = nil
                    state.selectionSourceElementIDAction = nil
                    state.path.pop(from: elementID)
                    let eventDetailAction = context.onCancelled()
                    guard let sourceID else { return .none }
                    switch sourceID {
                    case let .eventDetail(eventDetailID):
                        return .send(
                            .path(
                                .element(
                                    id: eventDetailID,
                                    action: .eventDetail(eventDetailAction)
                                )
                            )
                        )
                    case let .markDetail(markDetailID):
                        guard let eventDetailID = state.markDetailSourceByElementID[markDetailID] else {
                            return .none
                        }
                        return .send(
                            .path(
                                .element(
                                    id: eventDetailID,
                                    action: .eventDetail(eventDetailAction)
                                )
                            )
                        )
                    case let .linkDetail(linkDetailID):
                        guard let eventDetailID = state.linkDetailSourceByElementID[linkDetailID] else {
                            return .none
                        }
                        return .send(
                            .path(
                                .element(
                                    id: eventDetailID,
                                    action: .eventDetail(eventDetailAction)
                                )
                            )
                        )
                    }
                }
                guard let context = state.selectionContextAction else { return .none }
                state.selectionContextAction = nil
                state.path.pop(from: elementID)
                return .send(context.onCancelled())


            // ============================
            // MARK: EventDetail → Root（delegate）
            // ============================

            case let .path(
              .element(id: elementID, action: .eventDetail(.core(.delegate(.saved))))
            ):
                return .send(.eventList(.appeared))

            case let .path(
                .element(id: elementID, action: .eventDetail(.delegate(.dismiss)))
            ):
                state.path.pop(from: elementID)
                return .none
//                // 1) 一覧再読込指示
//                let reload = Effect.send(RootReducer.Action.eventList(.appeared))
//
//                // 2) 同じ elementID を pop（どの eventDetail を閉じるか明確）
//                state.path.pop(from: elementID)
//
//                // 3) effect を返す
//                return reload

            case let .path(
                .element(id: elementID, action: .eventDetail(.delegate(.openMarkDetail(markLinkID))))
            ):
                guard case let .eventDetail(eventDetailState)? = state.path[id: elementID] else { return .none }
                guard let itemProjection = eventDetailState.core.projection.michiInfo.items
                    .first(where: { $0.id == markLinkID })
                else { return .none }
                let markDetailDraft = eventDetailState.core.michiInfo.draftByID[markLinkID]
                    ?? MarkDetailDraft(projection: itemProjection)
                state.path.append(
                    .markDetail(
                        MarkDetailReducer.State(
                            markLinkID: markLinkID,
                            projection: itemProjection,
                            draft: markDetailDraft
                        )
                    )
                )
                if let newID = state.path.ids.last {
                    state.markDetailSourceByElementID[newID] = elementID
                }
                return .none

            case let .path(
                .element(id: elementID, action: .eventDetail(.delegate(.openLinkDetail(markLinkID))))
            ):
                guard case let .eventDetail(eventDetailState)? = state.path[id: elementID] else { return .none }
                guard let itemProjection = eventDetailState.core.projection.michiInfo.items
                    .first(where: { $0.id == markLinkID })
                else { return .none }
                let linkDetailDraft = eventDetailState.core.michiInfo.linkDraftByID[markLinkID]
                    ?? LinkDetailDraft(projection: itemProjection)
                state.path.append(
                    .linkDetail(
                        LinkDetailReducer.State(
                            markLinkID: markLinkID,
                            projection: itemProjection,
                            draft: linkDetailDraft
                        )
                    )
                )
                if let newID = state.path.ids.last {
                    state.linkDetailSourceByElementID[newID] = elementID
                }
                return .none

            case let .path(
                .element(id: elementID, action: .eventDetail(.delegate(.openPaymentDetail(paymentID))))
            ):
                guard case let .eventDetail(eventDetailState)? = state.path[id: elementID] else { return .none }
                guard let paymentProjection = eventDetailState.core.projection.paymentInfo.items
                    .first(where: { $0.id == paymentID })
                else { return .none }
                state.path.append(
                    .paymentDetail(
                        PaymentDetailReducer.State(
                            projection: paymentProjection,
                            eventID: eventDetailState.core.eventID,
                            paymentID: paymentID
                        )
                    )
                )
                return .none

            case let .path(
                .element(id: elementID, action: .markDetail(.delegate(.applied(draft))))
            ):
                guard let eventDetailID = state.markDetailSourceByElementID[elementID],
                      case let .markDetail(markDetailState)? = state.path[id: elementID]
                else { return .none }
                state.markDetailSourceByElementID[elementID] = nil
                state.path.pop(from: elementID)
                return .send(
                    .path(
                        .element(
                            id: eventDetailID,
                            action: .eventDetail(
                                .core(
                                    .michiInfo(
                                        .markDetailDraftApplied(markDetailState.markLinkID, draft)
                                    )
                                )
                            )
                        )
                    )
                )

            case let .path(
                .element(id: elementID, action: .linkDetail(.delegate(.applied(draft))))
            ):
                guard let eventDetailID = state.linkDetailSourceByElementID[elementID],
                      case let .linkDetail(linkDetailState)? = state.path[id: elementID]
                else { return .none }
                state.linkDetailSourceByElementID[elementID] = nil
                state.path.pop(from: elementID)
                return .send(
                    .path(
                        .element(
                            id: eventDetailID,
                            action: .eventDetail(
                                .core(
                                    .michiInfo(
                                        .linkDetailDraftApplied(linkDetailState.markLinkID, draft)
                                    )
                                )
                            )
                        )
                    )
                )

            case let .path(
                .element(id: elementID, action: .markDetail(.delegate(.memberSelectionRequested(ids))))
            ):
                guard let eventDetailID = state.markDetailSourceByElementID[elementID],
                      case let .markDetail(markDetailState)? = state.path[id: elementID]
                else { return .none }
                state.selectionSourceElementIDMember = .markDetail(elementID)
                return .send(
                    .path(
                        .element(
                            id: eventDetailID,
                            action: .eventDetail(
                                .core(.markDetailMemberSelectionRequested(markDetailState.markLinkID, ids))
                            )
                        )
                    )
                )

            case let .path(
                .element(id: elementID, action: .markDetail(.delegate(.actionSelectionRequested(ids))))
            ):
                guard let eventDetailID = state.markDetailSourceByElementID[elementID],
                      case let .markDetail(markDetailState)? = state.path[id: elementID]
                else { return .none }
                state.selectionSourceElementIDAction = .markDetail(elementID)
                return .send(
                    .path(
                        .element(
                            id: eventDetailID,
                            action: .eventDetail(
                                .core(.markDetailActionSelectionRequested(markDetailState.markLinkID, ids))
                            )
                        )
                    )
                )

            case let .path(
                .element(id: elementID, action: .linkDetail(.delegate(.memberSelectionRequested(ids))))
            ):
                guard let eventDetailID = state.linkDetailSourceByElementID[elementID],
                      case let .linkDetail(linkDetailState)? = state.path[id: elementID]
                else { return .none }
                state.selectionSourceElementIDMember = .linkDetail(elementID)
                return .send(
                    .path(
                        .element(
                            id: eventDetailID,
                            action: .eventDetail(
                                .core(.linkDetailMemberSelectionRequested(linkDetailState.markLinkID, ids))
                            )
                        )
                    )
                )

            case let .path(
                .element(id: elementID, action: .linkDetail(.delegate(.actionSelectionRequested(ids))))
            ):
                guard let eventDetailID = state.linkDetailSourceByElementID[elementID],
                      case let .linkDetail(linkDetailState)? = state.path[id: elementID]
                else { return .none }
                state.selectionSourceElementIDAction = .linkDetail(elementID)
                return .send(
                    .path(
                        .element(
                            id: eventDetailID,
                            action: .eventDetail(
                                .core(.linkDetailActionSelectionRequested(linkDetailState.markLinkID, ids))
                            )
                        )
                    )
                )

            case let .path(.popFrom(id: elementID)):
                state.markDetailSourceByElementID[elementID] = nil
                state.linkDetailSourceByElementID[elementID] = nil
                if case .markDetail(elementID) = state.selectionSourceElementIDMember {
                    state.selectionSourceElementIDMember = nil
                }
                if case .linkDetail(elementID) = state.selectionSourceElementIDMember {
                    state.selectionSourceElementIDMember = nil
                }
                if case .markDetail(elementID) = state.selectionSourceElementIDAction {
                    state.selectionSourceElementIDAction = nil
                }
                if case .linkDetail(elementID) = state.selectionSourceElementIDAction {
                    state.selectionSourceElementIDAction = nil
                }
                return .none
                
            // ============================
            // MARK: Settings → Root（Navigation）
            // ============================

            case let .path(
                .element(id: _, action: .settings(action))
            ):
                switch action {

                case .transSettingSelected:
                    state.path.append(.transSetting(TransSettingReducer.State()))
                    return .none

                case .memberSettingSelected:
                    state.path.append(.memberSetting(MemberSettingReducer.State()))
                    return .none

                case .tagSettingSelected:
                    state.path.append(.tagSetting(TagSettingReducer.State()))
                    return .none

                case .actionSettingSelected:
                    state.path.append(.actionSetting(ActionSettingReducer.State()))
                    return .none

                case .backTapped:
                    return .none
                }

            // MARK: 選択画面遷移
                
                
                
            // MARK: Trans
            case let .path(
                .element(id: elementID,
                         action: .eventDetail(.delegate(.transSelectionRequested(context: context, items: items))))
            ):
                state.selectionContextTrans = context
                state.selectionSourceElementIDTrans = elementID
                state.path.append(
                    .transSelection(
                        SelectionFeature<TransID>.State(
                            items: items,
                            selected: context.preselected,
                            allowsMultipleSelection: context.allowsMultipleSelection
                        )
                    )
                )
                return .none
                
            // MARK: Member
            // BasicInfo
            // TotalMember
            case let .path(
                .element(id: elementID,
                         action: .eventDetail(.delegate(.totalMembersSelectionRequested(context: context, items: items))))
            ):
                state.selectionContextMember = context
                state.selectionSourceElementIDMember = .eventDetail(elementID)
                state.path.append(
                    .memberSelection(
                        SelectionFeature<MemberID>.State(
                            items: items,
                            selected: context.preselected,
                            allowsMultipleSelection: context.allowsMultipleSelection
                        )
                    )
                )
                return .none
            // GasPaymember
            case let .path(
                .element(id: elementID,
                         action: .eventDetail(.delegate(.gasPayMemberSelectionRequested(context: context, items: items))))
            ):
                state.selectionContextMember = context
                state.selectionSourceElementIDMember = .eventDetail(elementID)
                state.path.append(
                    .memberSelection(
                        SelectionFeature<MemberID>.State(
                            items: items,
                            selected: context.preselected,
                            allowsMultipleSelection: context.allowsMultipleSelection
                        )
                    )
                )
                return .none
            // MarkDetail members selection (EventDetail delegate)
            case let .path(
                .element(id: elementID,
                         action: .eventDetail(.delegate(.markDetailMemberSelectionRequested(context: context, items: items))))
            ):
                state.selectionContextMember = context
                if state.selectionSourceElementIDMember == nil {
                    state.selectionSourceElementIDMember = .eventDetail(elementID)
                }
                state.path.append(
                    .memberSelection(
                        SelectionFeature<MemberID>.State(
                            items: items,
                            selected: context.preselected,
                            allowsMultipleSelection: context.allowsMultipleSelection
                        )
                    )
                )
                return .none
            // LinkDetail members selection (EventDetail delegate)
            case let .path(
                .element(id: elementID,
                         action: .eventDetail(.delegate(.linkDetailMemberSelectionRequested(context: context, items: items))))
            ):
                state.selectionContextMember = context
                if state.selectionSourceElementIDMember == nil {
                    state.selectionSourceElementIDMember = .eventDetail(elementID)
                }
                state.path.append(
                    .memberSelection(
                        SelectionFeature<MemberID>.State(
                            items: items,
                            selected: context.preselected,
                            allowsMultipleSelection: context.allowsMultipleSelection
                        )
                    )
                )
                return .none
            // MARK: Tag
            case let .path(
                .element(id: elementID,
                         action: .eventDetail(.delegate(.tagSelectionRequested(context: context, items: items))))
            ):
                state.selectionContextTag = context
                state.selectionSourceElementIDTag = elementID
                state.path.append(
                    .tagSelection(
                        SelectionFeature<TagID>.State(
                            items: items,
                            selected: context.preselected,
                            allowsMultipleSelection: context.allowsMultipleSelection
                        )
                    )
                )
                return .none
            // MARK: Action
            // MichiInfo
            case let .path(
                .element(id: elementID,
                         action: .eventDetail(.delegate(.markDetailActionSelectionRequested(context: context, items: items))))):
                state.selectionContextActionEventDetail = context
                if state.selectionSourceElementIDAction == nil {
                    state.selectionSourceElementIDAction = .eventDetail(elementID)
                }
                state.path.append(
                    .actionSelection(
                        SelectionFeature<ActionID>.State(
                            items: items,
                            selected: context.preselected,
                            allowsMultipleSelection: context.allowsMultipleSelection
                        )
                    )
                )
                return .none
            case let .path(
                .element(id: elementID,
                         action: .eventDetail(.delegate(.linkDetailActionSelectionRequested(context: context, items: items))))):
                state.selectionContextActionEventDetail = context
                if state.selectionSourceElementIDAction == nil {
                    state.selectionSourceElementIDAction = .eventDetail(elementID)
                }
                state.path.append(
                    .actionSelection(
                        SelectionFeature<ActionID>.State(
                            items: items,
                            selected: context.preselected,
                            allowsMultipleSelection: context.allowsMultipleSelection
                        )
                    )
                )
                return .none
                
            // MARK: 選択結果返送
            // MARK: Trans
            case let .path(
                .element(
                    id: _,
                    action: .transSelect(.delegate(.selected(id, name)))
                )
            ):
                guard
                    let eventDetailID = state.path.ids.dropLast().last
                else { return .none }
                state.path.removeLast()
                return .send(
                    .path(
                        .element(
                            id: eventDetailID,
                            action: .eventDetail(.transSelectionResultReceived(id, name))
                        )
                    )
                )

                
            // MARK: Member
            case let .path(
                .element(
                    id: _,
                    action: .memberSelect(.delegate(.selected(ids, names, useCase)))
                )
            ):
                switch useCase {
                case .totalMembers:
                    guard let eventDetailID = state.path.ids.dropLast().last
                    else { return .none }
                    state.path.removeLast()
                    return .send(
                        .path(
                            .element(
                                id: eventDetailID,
                                action: .eventDetail(.totalMembersSelectionResultReceived(ids, names))
                            )
                        )
                    )
                case .gasPayer:
                    guard let eventDetailID = state.path.ids.dropLast().last
                    else { return .none }
                    let payerID = ids.first
                    let payerName = payerID.flatMap { names[$0] }
                    state.path.removeLast()
                    return .send(
                        .path(
                            .element(
                                id: eventDetailID,
                                action: .eventDetail(.gasPayMemberSelectionResultReceived(payerID, payerName))
                            )
                        )
                    )
                    
                case .markMembers:
                    guard let eventDetailID = state.path.ids.dropLast().last
                    else { return .none }
                    guard
                        let markDetailID = state.path.ids.reversed().first(where: { id in
                            if case .markDetail? = state.path[id: id] { return true }
                            return false
                        }),
                        case let .markDetail(markDetailState)? = state.path[id: markDetailID]
                    else { return .none }
                    return .send(
                        .path(
                            .element(
                                id: eventDetailID,
                                action: .eventDetail(
                                    .markDetailMemberSelectionResultReceived(markDetailState.markLinkID, ids, names)
                                )
                            )
                        )
                    )
                default:
                    return .none
                }
                
            // MARK: Action
            case let .path(
                .element(
                    id: _,
                    action: .actionSelect(.delegate(.selected(ids, names, useCase)))
                )
            ):
                switch useCase {
                case .markActions:
                    guard let eventDetailID = state.path.ids.dropLast().last
                    else { return .none }
                    guard
                        let markDetailID = state.path.ids.reversed().first(where: { id in
                            if case .markDetail? = state.path[id: id] { return true }
                            return false
                        }),
                        case let .markDetail(markDetailState)? = state.path[id: markDetailID]
                    else { return .none }
                    state.path.removeLast()
                    return .send(
                        .path(
                            .element(
                                id: eventDetailID,
                                action: .eventDetail(
                                    .markDetailActionSelectionResultReceived(markDetailState.markLinkID, ids, names)
                                )
                            )
                        )
                    )

                case .linkActions:
                    // まだリンク詳細側の反映先が未実装のため、選択画面は閉じる
                    state.path.removeLast()
                    return .none
                }

            // MARK: Tag
            case let .path(
                .element(
                    id: _,
                    action: .tagSelect(.delegate(.selected(ids, names)))
                )
            ):
                guard let eventDetailID = state.path.ids.dropLast().last
                else { return .none }
                state.path.removeLast()
                return .send(
                    .path(
                        .element(
                            id: eventDetailID,
                            action: .eventDetail(.tagSelectionResultReceived(ids, names))
                        )
                    )
                )

            default:
                return .none
            }
        }

        .forEach(\.path, action: \.path)
    }
}
