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

    enum SelectionSource: Equatable {
        case eventDetail(StackElementID)
        case markDetail(StackElementID)
        case linkDetail(StackElementID)
        case paymentDetail(StackElementID)
    }

    struct PendingSelection: Equatable {
        let useCase: SelectionUseCase
        let source: SelectionSource
        let settingsElementID: StackElementID
    }

    @ObservableState
    struct State {
        // UI派生State（グローバル）
        var currentScreen: Screen = .eventList

        // NavigationStack
        var path = StackState<Path.State>()

        // 子Feature（常駐）
        var eventList = EventListReducer.State()

        // SelectionFeature の中継用
        var selectionSource: SelectionSource?
        var pendingSelection: PendingSelection?

        // EventDetail から開いた Mark/Link の追跡
        var markDetailSourceByElementID: [StackElementID: StackElementID] = [:]
        var linkDetailSourceByElementID: [StackElementID: StackElementID] = [:]
        
        // Draft（Rootが所有）
        var markDrafts: IdentifiedArrayOf<MarkDetailDraft> = []
        var linkDrafts: IdentifiedArrayOf<LinkDetailDraft> = []

        // 外部依存State
        var appMode: AppMode = .personal
    }

    enum Action {
        case eventList(EventListReducer.Action)
        case path(StackAction<Path.State, Path.Action>)
        case selectionItemsLoaded(
            useCase: SelectionUseCase,
            items: [SelectionItem],
            preselectedIDs: Set<UUID>,
            source: SelectionSource
        )
    }
    
    @Dependency(\.eventRepositoryProtocol) var eventRepositoryProtocol
    @Dependency(\.transRepository) var transRepository
    @Dependency(\.memberRepository) var memberRepository
    @Dependency(\.tagRepository) var tagRepository
    @Dependency(\.actionRepository) var actionRepository

    @Reducer
    enum Path {
        //設定系
        case settings(SettingsReducer)
        case transSetting(TransSettingReducer)
        case transSettingCreate(TransSettingCreateReducer)
        case memberSetting(MemberSettingReducer)
        case memberSettingCreate(MemberSettingCreateReducer)
        case tagSetting(TagSettingReducer)
        case tagSettingCreate(TagSettingCreateReducer)
        case actionSetting(ActionSettingReducer)
        case actionSettingCreate(ActionSettingCreateReducer)
        //イベント詳細
        case eventDetail(EventDetailReducer)
        case markDetail(MarkDetailReducer)
        case linkDetail(LinkDetailReducer)
        case paymentDetail(PaymentDetailReducer)
        //選択
        case selection(SelectionFeature)
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
                let markDrafts = IdentifiedArray(
                    uniqueElements: projection.michiInfo.items
                        .filter { $0.markLinkType == .mark }
                        .map { MarkDetailDraft(projection: $0) }
                )
                let linkDrafts = IdentifiedArray(
                    uniqueElements: projection.michiInfo.items
                        .filter { $0.markLinkType == .link }
                        .map { LinkDetailDraft(projection: $0) }
                )
                state.markDrafts = markDrafts
                state.linkDrafts = linkDrafts

                var eventDetailState = EventDetailReducer.State(projection: projection)
                eventDetailState.core.michiInfo.markDrafts = markDrafts
                eventDetailState.core.michiInfo.linkDrafts = linkDrafts
                state.path.append(.eventDetail(eventDetailState))
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

                let markDrafts = IdentifiedArray(
                    uniqueElements: projection.michiInfo.items
                        .filter { $0.markLinkType == .mark }
                        .map { MarkDetailDraft(projection: $0) }
                )
                let linkDrafts = IdentifiedArray(
                    uniqueElements: projection.michiInfo.items
                        .filter { $0.markLinkType == .link }
                        .map { LinkDetailDraft(projection: $0) }
                )
                state.markDrafts = markDrafts
                state.linkDrafts = linkDrafts

                var eventDetailState = EventDetailReducer.State(projection: projection)
                eventDetailState.core.michiInfo.markDrafts = markDrafts
                eventDetailState.core.michiInfo.linkDrafts = linkDrafts
                state.path.append(.eventDetail(eventDetailState))
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
            case let .selectionItemsLoaded(useCase, items, preselectedIDs, source):
                state.selectionSource = source
                var resolvedItems = items
                var resolvedPreselectedIDs = preselectedIDs
                switch useCase {
                case .eventTrans, .eventTags, .gasPayMember:
                    if case let .eventDetail(elementID) = source,
                       case let .eventDetail(eventDetailState)? = state.path[id: elementID] {
                        let draft = eventDetailState.core.basicInfo.draft
                        switch useCase {
                        case .eventTrans:
                            resolvedPreselectedIDs = draft.selectedTransID.map { [$0] } ?? []
                        case .eventTags:
                            resolvedPreselectedIDs = draft.selectedTagIDs
                        case .gasPayMember:
                            resolvedPreselectedIDs = draft.selectedPayMemberID.map { [$0] } ?? []
                        default:
                            break
                        }
                    }
                default:
                    break
                }
                let selectionState = SelectionFactory.make(
                    useCase: useCase,
                    items: resolvedItems,
                    preselectedIDs: resolvedPreselectedIDs
                )
                state.path.append(.selection(selectionState))
                return .none

            case let .path(
                .element(id: elementID, action: .selection(.delegate(.completed(useCase, ids, names))))
            ):
                guard let source = state.selectionSource else { return .none }
                state.selectionSource = nil
                state.path.pop(from: elementID)

                switch source {
                case let .eventDetail(targetID):
                    return .send(
                        .path(
                            .element(
                                id: targetID,
                                action: .eventDetail(
                                    .core(
                                    .basicInfo(
                                        .applySelection(
                                            useCase: useCase,
                                            ids: ids,
                                            names: names
                                        )
                                    )
                                )
                            )
                        )
                        )
                    )

                case let .markDetail(targetID):
                    return .send(
                        .path(
                            .element(
                                id: targetID,
                                action: .markDetail(
                                    .applySelection(
                                        useCase: useCase,
                                        ids: ids,
                                        names: names
                                    )
                                )
                            )
                        )
                    )

                case let .linkDetail(targetID):
                    return .send(
                        .path(
                            .element(
                                id: targetID,
                                action: .linkDetail(
                                    .applySelection(
                                        useCase: useCase,
                                        ids: ids,
                                        names: names
                                    )
                                )
                            )
                        )
                    )

                case let .paymentDetail(targetID):
                    return .send(
                        .path(
                            .element(
                                id: targetID,
                                action: .paymentDetail(
                                    .applySelection(
                                        useCase: useCase,
                                        ids: ids,
                                        names: names
                                    )
                                )
                            )
                        )
                    )
                }

            case let .path(
                .element(id: _, action: .selection(.delegate(.requestCreate(useCase))))
            ):
                guard state.selectionSource != nil else { return .none }
                appendSettingCreate(for: useCase, state: &state)
                return .none

            case let .path(
                .element(
                    id: _,
                    action: .transSetting(.detail(.presented(.delegate(.didSave(id)))))
                )
            ):
                return handleSettingDidSave(createdID: id, state: &state)

            case let .path(
                .element(
                    id: _,
                    action: .actionSetting(.detail(.presented(.delegate(.didSave(id)))))
                )
            ):
                return handleSettingDidSave(createdID: id, state: &state)

            case let .path(
                .element(
                    id: _,
                    action: .memberSetting(.detail(.presented(.delegate(.didSave(id)))))
                )
            ):
                return handleSettingDidSave(createdID: id, state: &state)

            case let .path(
                .element(
                    id: _,
                    action: .tagSetting(.detail(.presented(.delegate(.didSave(id)))))
                )
            ):
                return handleSettingDidSave(createdID: id, state: &state)

            case let .path(
                .element(
                    id: _,
                    action: .transSettingCreate(.detail(.delegate(.didSave(id))))
                )
            ):
                return handleSettingDidSave(createdID: id, state: &state)

            case let .path(
                .element(
                    id: _,
                    action: .memberSettingCreate(.detail(.delegate(.didSave(id))))
                )
            ):
                return handleSettingDidSave(createdID: id, state: &state)

            case let .path(
                .element(
                    id: _,
                    action: .tagSettingCreate(.detail(.delegate(.didSave(id))))
                )
            ):
                return handleSettingDidSave(createdID: id, state: &state)

            case let .path(
                .element(
                    id: _,
                    action: .actionSettingCreate(.detail(.delegate(.didSave(id))))
                )
            ):
                return handleSettingDidSave(createdID: id, state: &state)


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
                let markDetailDraft: MarkDetailDraft
                let itemProjection: MarkLinkItemProjection
                if let draft = state.markDrafts[id: markLinkID] {
                    markDetailDraft = draft
                    itemProjection = draft.toProjection()
                } else if let projection = eventDetailState.core.projection.michiInfo.items
                    .first(where: { $0.id == markLinkID }) {
                    markDetailDraft = MarkDetailDraft(projection: projection)
                    itemProjection = projection
                } else {
                    return .none
                }
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
                let linkDetailDraft: LinkDetailDraft
                let itemProjection: MarkLinkItemProjection
                if let draft = state.linkDrafts[id: markLinkID] {
                    linkDetailDraft = draft
                    itemProjection = draft.toProjection()
                } else if let projection = eventDetailState.core.projection.michiInfo.items
                    .first(where: { $0.id == markLinkID }) {
                    linkDetailDraft = LinkDetailDraft(projection: projection)
                    itemProjection = projection
                } else {
                    return .none
                }
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
                .element(id: elementID, action: .eventDetail(.delegate(.addMarkOrLinkSelected(type))))
            ):
                guard case .eventDetail = state.path[id: elementID] else { return .none }
                let newMarkLinkID = MarkLinkID()
                let allSeq = state.markDrafts.map(\.markLinkSeq) + state.linkDrafts.map(\.markLinkSeq)
                let nextSeq = (allSeq.max() ?? 0) + 1
                switch type {
                case .mark:
                    let draft = MarkDetailDraft.new(id: newMarkLinkID, markLinkSeq: nextSeq)
                    let projection = draft.toProjection()
                    state.path.append(
                        .markDetail(
                            MarkDetailReducer.State(
                                markLinkID: newMarkLinkID,
                                projection: projection,
                                draft: draft
                            )
                        )
                    )
                    if let newID = state.path.ids.last {
                        state.markDetailSourceByElementID[newID] = elementID
                    }
                case .link:
                    let draft = LinkDetailDraft.new(id: newMarkLinkID, markLinkSeq: nextSeq)
                    let projection = draft.toProjection()
                    state.path.append(
                        .linkDetail(
                            LinkDetailReducer.State(
                                markLinkID: newMarkLinkID,
                                projection: projection,
                                draft: draft
                            )
                        )
                    )
                    if let newID = state.path.ids.last {
                        state.linkDetailSourceByElementID[newID] = elementID
                    }
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
                .element(id: elementID, action: .markDetail(.delegate(.saved(draft))))
            ):
                guard let eventDetailID = state.markDetailSourceByElementID[elementID] else { return .none }
                state.markDrafts[id: draft.id] = draft
                state.markDetailSourceByElementID[elementID] = nil
                state.path.pop(from: elementID)
                syncMichiInfoDrafts(for: eventDetailID, state: &state)
                return .none

            case let .path(
                .element(id: elementID, action: .linkDetail(.delegate(.saved(draft))))
            ):
                guard let eventDetailID = state.linkDetailSourceByElementID[elementID] else { return .none }
                state.linkDrafts[id: draft.id] = draft
                state.linkDetailSourceByElementID[elementID] = nil
                state.path.pop(from: elementID)
                syncMichiInfoDrafts(for: eventDetailID, state: &state)
                return .none

            case let .path(
                .element(id: elementID, action: .paymentDetail(.delegate(.selectionRequested(useCase))))
            ):
                return requestSelection(
                    useCase: useCase,
                    source: .paymentDetail(elementID),
                    state: &state
                )

            case let .path(
                .element(id: elementID, action: .markDetail(.delegate(.selectionRequested(useCase))))
            ):
                return requestSelection(
                    useCase: useCase,
                    source: .markDetail(elementID),
                    state: &state
                )

            case let .path(
                .element(id: elementID, action: .linkDetail(.delegate(.selectionRequested(useCase))))
            ):
                return requestSelection(
                    useCase: useCase,
                    source: .linkDetail(elementID),
                    state: &state
                )

            case let .path(.popFrom(id: elementID)):
                state.markDetailSourceByElementID[elementID] = nil
                state.linkDetailSourceByElementID[elementID] = nil
                if let pending = state.pendingSelection,
                   pending.settingsElementID == elementID {
                    state.pendingSelection = nil
                    return requestSelection(
                        useCase: pending.useCase,
                        source: pending.source,
                        state: &state
                    )
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
            case let .path(
                .element(id: elementID, action: .eventDetail(.delegate(.selectionRequested(useCase))))
            ):
                return requestSelection(
                    useCase: useCase,
                    source: .eventDetail(elementID),
                    state: &state
                )

            default:
                return .none
            }
        }

        .forEach(\.path, action: \.path)
    }

    private func syncMichiInfoDrafts(
        for elementID: StackElementID,
        state: inout State
    ) {
        guard case var .eventDetail(eventDetailState) = state.path[id: elementID] else { return }
        eventDetailState.core.michiInfo.markDrafts = state.markDrafts
        eventDetailState.core.michiInfo.linkDrafts = state.linkDrafts
        state.path[id: elementID] = .eventDetail(eventDetailState)
    }

    private func requestSelection(
        useCase: SelectionUseCase,
        source: SelectionSource,
        state: inout State
    ) -> Effect<Action> {
        let preselectedIDs = selectionPreselectedIDs(
            useCase: useCase,
            source: source,
            state: state
        )
        return .run { [useCase, preselectedIDs, source] send in
            let items: [SelectionItem]
            do {
                items = try await fetchSelectionItems(useCase: useCase)
            } catch {
                items = []
            }
            await send(
                .selectionItemsLoaded(
                    useCase: useCase,
                    items: items,
                    preselectedIDs: preselectedIDs,
                    source: source
                )
            )
        }
    }

    private func fetchSelectionItems(useCase: SelectionUseCase) async throws -> [SelectionItem] {
        switch useCase {
        case .eventTrans:
            let domains = try await transRepository.fetchAll()
            let projections = TransProjectionAdapter()
                .adaptList(transes: domains)
                .filter { $0.isVisible }
            return projections.map { projection in
                let subtitleParts = [
                    projection.displayKmPerGas.isEmpty ? nil : "燃費 \(projection.displayKmPerGas)",
                    projection.displayMeterValue.isEmpty ? nil : "メーター \(projection.displayMeterValue)"
                ].compactMap { $0 }
                let subtitle = subtitleParts.isEmpty ? nil : subtitleParts.joined(separator: " / ")
                return SelectionItem(
                    id: projection.id,
                    title: projection.transName,
                    subtitle: subtitle
                )
            }

        case .eventMembers, .gasPayMember, .markMembers, .linkMembers, .payMember, .splitMembers:
            let domains = try await memberRepository.fetchAll()
            let projections = MemberProjectionAdapter()
                .adaptList(members: domains)
                .filter { $0.isVisible }
            return projections.map { projection in
                let subtitle = projection.mailAddress?.isEmpty == false
                    ? projection.mailAddress
                    : nil
                return SelectionItem(
                    id: projection.id,
                    title: projection.memberName,
                    subtitle: subtitle
                )
            }

        case .eventTags:
            let domains = try await tagRepository.fetchAll()
            let projections = TagProjectionAdapter()
                .adaptList(tags: domains)
                .filter { $0.isVisible }
            return projections.map { projection in
                SelectionItem(
                    id: projection.id,
                    title: projection.tagName,
                    subtitle: nil
                )
            }

        case .markActions, .linkActions:
            let domains = try await actionRepository.fetchAll()
            let projections = ActionProjectionAdapter()
                .adaptList(actions: domains)
                .filter { $0.isVisible }
            return projections.map { projection in
                SelectionItem(
                    id: projection.id,
                    title: projection.actionName,
                    subtitle: nil
                )
            }
        }
    }

    private func selectionPreselectedIDs(
        useCase: SelectionUseCase,
        source: SelectionSource,
        state: State
    ) -> Set<UUID> {
        switch useCase {
        case .eventTrans, .eventMembers, .eventTags, .gasPayMember:
            guard case let .eventDetail(elementID) = source,
                  case let .eventDetail(eventDetailState)? = state.path[id: elementID]
            else { return [] }
            let draft = eventDetailState.core.basicInfo.draft
            switch useCase {
            case .eventTrans:
                return draft.selectedTransID.map { [$0] } ?? []
            case .eventMembers:
                return draft.selectedMemberIDs
            case .eventTags:
                return draft.selectedTagIDs
            case .gasPayMember:
                return draft.selectedPayMemberID.map { [$0] } ?? []
            default:
                return []
            }

        case .markMembers, .markActions:
            guard case let .markDetail(elementID) = source,
                  case let .markDetail(markDetailState)? = state.path[id: elementID]
            else { return [] }
            switch useCase {
            case .markMembers:
                return markDetailState.draft.selectedMemberIDs
            case .markActions:
                return markDetailState.draft.selectedActionIDs
            default:
                return []
            }

        case .linkMembers, .linkActions:
            guard case let .linkDetail(elementID) = source,
                  case let .linkDetail(linkDetailState)? = state.path[id: elementID]
            else { return [] }
            switch useCase {
            case .linkMembers:
                return linkDetailState.draft.selectedMemberIDs
            case .linkActions:
                return linkDetailState.draft.selectedActionIDs
            default:
                return []
            }

        case .payMember, .splitMembers:
            guard case let .paymentDetail(elementID) = source,
                  case let .paymentDetail(paymentDetailState)? = state.path[id: elementID]
            else { return [] }
            switch useCase {
            case .payMember:
                return paymentDetailState.draft.payMemberID.map { [$0] } ?? []
            case .splitMembers:
                return paymentDetailState.draft.splitMemberIDs
            default:
                return []
            }
        }
    }

    private func appendSettingCreate(
        for useCase: SelectionUseCase,
        state: inout State
    ) {
        switch useCase {
        case .eventTrans:
            state.path.append(.transSettingCreate(TransSettingCreateReducer.State()))

        case .eventMembers,
             .gasPayMember,
             .markMembers,
             .linkMembers,
             .payMember,
             .splitMembers:
            state.path.append(.memberSettingCreate(MemberSettingCreateReducer.State()))

        case .eventTags:
            state.path.append(.tagSettingCreate(TagSettingCreateReducer.State()))

        case .markActions, .linkActions:
            state.path.append(.actionSettingCreate(ActionSettingCreateReducer.State()))
        }
    }

    private func handleSettingDidSave(
        createdID: UUID,
        state: inout State
    ) -> Effect<Action> {

        let ids = Array(state.path.ids)
        guard ids.count >= 2 else { return .none }

        let previousID = ids[ids.count - 2]

        guard case let .selection(selectionState) = state.path[id: previousID]
        else {
            state.path.removeLast()
            return .none
        }

        let isMultipleSelection = selectionState.isMultipleSelection

        state.path.removeLast()

        if isMultipleSelection {
            return .send(
                .path(
                    .element(
                        id: previousID,
                        action: .selection(.reloadAfterCreate(createdID: createdID))
                    )
                )
            )
        }

        return .send(
            .path(
                .element(
                    id: previousID,
                    action: .selection(.reloadAfterCreate(createdID: createdID))
                )
            )
        )
    }


}
