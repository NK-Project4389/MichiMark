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
        var selectionSourceElementIDMember: StackElementID?
        var selectionContextTag: SelectionContext<TagID, EventDetailReducer.Action>?
        var selectionSourceElementIDTag: StackElementID?
        var selectionContextAction: SelectionContext<ActionID, Action>?
        var selectionContextActionEventDetail: SelectionContext<ActionID, EventDetailReducer.Action>?
        var selectionSourceElementIDAction: StackElementID?

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
                guard
                    let context = state.selectionContextTrans,
                    let sourceID = state.selectionSourceElementIDTrans
                else { return .none }
                state.selectionContextTrans = nil
                state.selectionSourceElementIDTrans = nil
                state.path.pop(from: elementID)
                // Root は ID の意味解釈をせず、SelectionContext のクロージャへ中継するだけ
                let eventDetailAction = context.onSelected(ids)
                if case .destination(.dismiss) = eventDetailAction { return .none }
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
                guard
                    let context = state.selectionContextTrans,
                    let sourceID = state.selectionSourceElementIDTrans
                else { return .none }
                state.selectionContextTrans = nil
                state.selectionSourceElementIDTrans = nil
                state.path.pop(from: elementID)
                let eventDetailAction = context.onCancelled()
                if case .destination(.dismiss) = eventDetailAction { return .none }
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
                guard
                    let context = state.selectionContextMember,
                    let sourceID = state.selectionSourceElementIDMember
                else { return .none }
                state.selectionContextMember = nil
                state.selectionSourceElementIDMember = nil
                state.path.pop(from: elementID)
                // Root は ID の意味解釈をせず、SelectionContext のクロージャへ中継するだけ
                let eventDetailAction = context.onSelected(ids)
                if case .destination(.dismiss) = eventDetailAction { return .none }
                return .send(
                    .path(
                        .element(
                            id: sourceID,
                            action: .eventDetail(eventDetailAction)
                        )
                    )
                )
                
            case let .path(
                .element(id: elementID, action: .memberSelection(.delegate(.cancelled)))
            ):
                guard
                    let context = state.selectionContextMember,
                    let sourceID = state.selectionSourceElementIDMember
                else { return .none }
                state.selectionContextMember = nil
                state.selectionSourceElementIDMember = nil
                state.path.pop(from: elementID)
                let eventDetailAction = context.onCancelled()
                if case .destination(.dismiss) = eventDetailAction { return .none }
                return .send(
                    .path(
                        .element(
                            id: sourceID,
                            action: .eventDetail(eventDetailAction)
                        )
                    )
                )
                
            case let .path(
                .element(id: elementID, action: .tagSelection(.delegate(.selected(ids))))
            ):
                guard
                    let context = state.selectionContextTag,
                    let sourceID = state.selectionSourceElementIDTag
                else { return .none }
                state.selectionContextTag = nil
                state.selectionSourceElementIDTag = nil
                state.path.pop(from: elementID)
                // Root は ID の意味解釈をせず、SelectionContext のクロージャへ中継するだけ
                let eventDetailAction = context.onSelected(ids)
                if case .destination(.dismiss) = eventDetailAction { return .none }
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
                guard
                    let context = state.selectionContextTag,
                    let sourceID = state.selectionSourceElementIDTag
                else { return .none }
                state.selectionContextTag = nil
                state.selectionSourceElementIDTag = nil
                state.path.pop(from: elementID)
                let eventDetailAction = context.onCancelled()
                if case .destination(.dismiss) = eventDetailAction { return .none }
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
                if let context = state.selectionContextActionEventDetail,
                   let sourceID = state.selectionSourceElementIDAction {
                    state.selectionContextActionEventDetail = nil
                    state.selectionSourceElementIDAction = nil
                    state.path.pop(from: elementID)
                    let eventDetailAction = context.onSelected(ids)
                    if case .destination(.dismiss) = eventDetailAction { return .none }
                    return .send(
                        .path(
                            .element(
                                id: sourceID,
                                action: .eventDetail(eventDetailAction)
                            )
                        )
                    )
                }
                guard let context = state.selectionContextAction else { return .none }
                state.selectionContextAction = nil
                state.path.pop(from: elementID)
                // Root は ID の意味解釈をせず、SelectionContext のクロージャへ中継するだけ
                return .send(context.onSelected(ids))
                
            case let .path(
                .element(id: elementID, action: .actionSelection(.delegate(.cancelled)))
            ):
                if let context = state.selectionContextActionEventDetail,
                   let sourceID = state.selectionSourceElementIDAction {
                    state.selectionContextActionEventDetail = nil
                    state.selectionSourceElementIDAction = nil
                    state.path.pop(from: elementID)
                    let eventDetailAction = context.onCancelled()
                    if case .destination(.dismiss) = eventDetailAction { return .none }
                    return .send(
                        .path(
                            .element(
                                id: sourceID,
                                action: .eventDetail(eventDetailAction)
                            )
                        )
                    )
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
                state.selectionSourceElementIDMember = elementID
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
                state.selectionSourceElementIDMember = elementID
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
                return .send(
                    .path(
                        .element(
                            id: elementID,
                            action: .eventDetail(
                                .presentMemberSelectionFromMarkDetail(
                                    context: context,
                                    items: items
                                )
                            )
                        )
                    )
                )
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
                return .send(
                    .path(
                        .element(
                            id: elementID,
                            action: .eventDetail(
                                .presentActionSelectionFromMarkDetail(
                                    context: context,
                                    items: items
                                )
                            )
                        )
                    )
                )
                
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
                    return .send(
                        .path(
                            .element(
                                id: eventDetailID,
                                action: .eventDetail(
                                    .markDetailMemberSelectionResultReceived(ids, names)
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
                    state.path.removeLast()
                    return .send(
                        .path(
                            .element(
                                id: eventDetailID,
                                action: .eventDetail(
                                    .markDetailActionSelectionResultReceived(ids, names)
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
