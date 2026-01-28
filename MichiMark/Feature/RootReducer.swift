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

        // 外部依存State
        var appMode: AppMode = .personal
    }

    enum Action {
        case eventList(EventListReducer.Action)
        case path(StackAction<Path.State, Path.Action>)
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
        //ミチ情報
        case markDetail(MarkDetailReducer)
        case linkDetail(LinkDetailReducer)
        //支払情報
        case paymentDetail(PaymentDetailReducer)
        //選択
        case transSelect(TransSelectReducer)
        case memberSelect(MemberSelectReducer)
        case tagSelect(TagSelectReducer)
        case actionSelect(ActionSelectReducer)
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
            // MARK: EventDetail → Root（delegate）
            // ============================
            //MichiInfo
            case let .path(.element(
                    id: elementID,
                    action: .eventDetail(.core(.delegate(.openMarkDetail(markLinkID))))
                )
            ):

                guard
                    let eventDetail = state.path[id: elementID]?.eventDetail,
                    let itemProjection = eventDetail.core.projection.michiInfo.items
                        .first(where: { $0.id == markLinkID })
                else {
                    return .none
                }
                
                let markDetailDraft = MarkDetailDraft.init(projection: itemProjection)

                state.path.append(
                    .markDetail(
                        MarkDetailReducer.State(
                            projection: itemProjection,
                            draft: markDetailDraft,
                            eventID: eventDetail.core.eventID,
                            markLinkID: markLinkID
                        )
                    )
                )
                return .none

            case let .path(.element(
                    id: elementID,
                    action: .eventDetail(.core(.delegate(.openLinkDetail(markLinkID))))
                )
            ):
                guard
                    let eventDetail = state.path[id: elementID]?.eventDetail,
                    let itemProjection = eventDetail.core.projection.michiInfo.items
                        .first(where: { $0.id == markLinkID })
                else {
                    return .none
                }

                state.path.append(
                    .linkDetail(
                        LinkDetailReducer.State(
                            projection: itemProjection,
                            eventID: eventDetail.core.eventID,
                            markLinkID: markLinkID
                        )
                    )
                )
                return .none

            case let .path(
                .element(
                    id: elementID,
                    action: .eventDetail(.core(.delegate(.openPaymentDetail(paymentID))))
                )
            ):
                guard
                    let eventDetail = state.path[id: elementID]?.eventDetail,
                    let paymentProjection = eventDetail.core.projection.paymentInfo.items
                        .first(where: { $0.id == paymentID })
                else {
                    return .none
                }

                state.path.append(
                    .paymentDetail(
                        PaymentDetailReducer.State(
                            projection: paymentProjection,
                            eventID: eventDetail.core.eventID,
                            paymentID: paymentID
                        )
                    )
                )
                return .none

            case let .path(
              .element(id: elementID, action: .eventDetail(.core(.delegate(.saved))))
            ):
                return .send(.eventList(.appeared))
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
                         action: .eventDetail(.core(.delegate(.openTransSelect))))
            ):
                guard
                    let eventDetail = state.path[id: elementID]?.eventDetail
                else { return .none }

                let selectedID = eventDetail.core.basicInfo.draft.selectedTransID

                state.path.append(
                    .transSelect(
                        TransSelectReducer.State(
                            items: [],
                            selectedID: selectedID
                        )
                    )
                )
                return .none
                
            // MARK: Member
            case let .path(
                .element(id: elementID,
                         action: .eventDetail(.core(.delegate(.openTotalMemberSelect(ids)))))
            ):
                guard
                    let eventDetail = state.path[id: elementID]?.eventDetail
                else { return .none }

                state.path.append(
                    .memberSelect(
                        MemberSelectReducer.State(
                            items: [],
                            selectedIDs: ids,
                            mode: .multiple,
                            useCase: .totalMembers
                        )
                    )
                )
                return .none
            
            // MARK: Tag
            case let .path(
                .element(id: elementID,
                         action: .eventDetail(.core(.delegate(.openTagSelect))))
            ):
                guard
                    let eventDetail = state.path[id: elementID]?.eventDetail
                else { return .none }
                
                let selectedIDs = eventDetail.core.basicInfo.draft.selectedTagIDs

                state.path.append(
                    .tagSelect(
                        TagSelectReducer.State(
                            items: [],
                            selectedIDs: selectedIDs
                        )
                    )
                )
                return .none
                
            // MARK: PayMember
            case let .path(
                .element(id: elementID,
                         action: .eventDetail(.core(.delegate(.openGasPayMemberSelect(ids)))))
            ):
                guard
                    let eventDetail = state.path[id: elementID]?.eventDetail
                else { return .none }

                state.path.append(
                    .memberSelect(
                        MemberSelectReducer.State(
                            items: [],
                            selectedIDs: ids,
                            mode: .single,
                            useCase: .gasPayer
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

                if case .eventDetail(var eventDetailState) = state.path[id: eventDetailID] {
                    eventDetailState.core.basicInfo.draft.selectedTransID = id
                    eventDetailState.core.basicInfo.draft.selectedTransName = name

                    state.path[id: eventDetailID] = .eventDetail(eventDetailState)
                }

                state.path.removeLast()
                return .none

                
            // MARK: Member
            case let .path(
                .element(
                    id: _,
                    action: .memberSelect(.delegate(.selected(ids, names, useCase)))
                )
            ):
                guard let eventDetailID = state.path.ids.dropLast().last
                else { return .none }

                switch useCase {
                case .totalMembers:
                    if case .eventDetail(var eventDetailState) = state.path[id: eventDetailID] {
                        eventDetailState.core.basicInfo.draft.selectedMemberIDs = ids
                        eventDetailState.core.basicInfo.draft.selectedMemberNames = names

                        state.path[id: eventDetailID] = .eventDetail(eventDetailState)
                    }
                    
                    state.path.removeLast()
                    return .none
                case .gasPayer:
                    if case .eventDetail(var eventDetailState) = state.path[id: eventDetailID] {
                        let payerID = ids.first
                        let payerName = payerID.flatMap { names[$0] }
                        eventDetailState.core.basicInfo.draft.selectedPayMemberID = ids.first
                        eventDetailState.core.basicInfo.draft.selectedPayMemberName = payerName

                        state.path[id: eventDetailID] = .eventDetail(eventDetailState)
                    }
                    
                    state.path.removeLast()
                    return .none
                default:
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

                if case .eventDetail(var eventDetailState) = state.path[id: eventDetailID] {
                    eventDetailState.core.basicInfo.draft.selectedTagIDs = ids
                    eventDetailState.core.basicInfo.draft.selectedTagNames = names

                    state.path[id: eventDetailID] = .eventDetail(eventDetailState)
                }

                state.path.removeLast()
                return .none

            default:
                return .none
            }
        }

        .forEach(\.path, action: \.path)
    }
}
