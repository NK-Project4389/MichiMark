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

    @Reducer
    enum Path {
        case eventDetail(EventDetailReducer)
        case settings(SettingsReducer)
        case transSetting(TransSettingReducer)
//        case transSettingDetail(TransSettingDetailReducer)
        case memberSetting(MemberSettingReducer)
//        case memberSettingDetail(MemberSettingDetailReducer)
        case tagSetting(TagSettingReducer)
//        case tagSettingDetail(TagSettingDetailReducer)
        case actionSetting(ActionSettingReducer)
        //case actionSettingDetail(ActionSettingDetailReducer)
        case markDetail(MarkDetailReducer)
        case linkDetail(LinkDetailReducer)
        case paymentDetail(PaymentDetailReducer)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.eventList, action: \.eventList) { EventListReducer() }

        //一時的なダミーProjection
        Reduce { state, action in
            switch action {

            // ============================
            // EventList → Root（Navigation）
            // ============================

//            case let .eventList(.eventTapped(eventID)):
//                state.path.append(
//                    .eventDetail(EventDetailReducer.State(eventID: eventID))
//                )
//                return .none
            case let .eventList(.eventTapped(eventID)):
                let projection = EventDetailProjection.empty(eventID: eventID)
                state.path.append(
                    .eventDetail(
                        EventDetailReducer.State(projection: projection)
                    )
                )

//                state.path.append(
////                    .eventDetail(
////                        EventDetailReducer.State(projection: projection)
////                    )
//                    .eventDetail(
//                        EventDetailReducer.State(
//                            core: EventDetailCoreReducer.State(
//                                eventID: eventID,
//                                projection: projection,
//                                basicInfo: .init(projection: projection.basicInfo),
//                                michiInfo: .init(projection: projection.michiInfo),
//                                paymentInfo: .init(projection: projection.paymentInfo),
//                                overview: .init(projection: projection.overview)
//                            )
//                        )
//                    )
//                )
                return .none

            case .eventList(.settingsButtonTapped):
                state.path.append(.settings(SettingsReducer.State()))
                return .none

            case .eventList(.addButtonTapped):
                let new = EventDomain(
                    id: UUID(),
                    eventName: "New Event",
                    trans: TransDomain(
                        id: UUID(),
                        transName: "車"
                    )
                    // createdAt / updatedAt は EventDomain 側 init のデフォルトで Date() が入ります
                )
                state.eventList.events.insert(new, at: 0)
                return .none


            case let .eventList(.deleteEventTapped(eventID)):
                state.eventList.events.removeAll { $0.id == eventID }
                return .none

            case .eventList(.appeared),
                 .eventList(.deleteResponse):
                return .none


            // ============================
            // EventDetail → Root（delegate）
            // ============================
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

                state.path.append(
                    .markDetail(
                        MarkDetailReducer.State(
                            projection: itemProjection,
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

            
            // ============================
            // EventDetail → Root（delegate）
            // ============================
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


                
            // ============================
            // EventDetail → Root（dismiss）
            // ============================

            case .path(
                .element(id: _, action: .eventDetail(.core(.delegate(.dismiss))))
            ):
              return .none
            
            // ============================
            // Settings → Root（Navigation）
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
            // ============================
            // TransSetting → Root
            // ============================

//            case let .path(
//                .element(_, action: .transSetting(action))
//            ):
//                switch action {
//
//                case let .transSelected(transID):
//                    let projection = TransItemProjection(
//                        domain: TransDomain(id: transID, transName: "")
//                    )
//                    state.path.append(
//                        .transSettingDetail(
//                            TransSettingDetailReducer.State(projection: projection)
//                        )
//                    )
//                    return .none
//
//                case .addTransTapped:
//                    let projection = TransItemProjection(
//                        domain: TransDomain(id: UUID(), transName: "")
//                    )
//                    state.path.append(
//                        .transSettingDetail(
//                            TransSettingDetailReducer.State(projection: projection)
//                        )
//                    )
//                    return .none
//                }
//            // ============================
            // TransSettingDetail → Root
            // ============================

//            case let .path(
//                .element(_, action: .transSettingDetail(action))
//            ):
//                switch action {
//                case .saveTapped, .backTapped:
////                    state.path.popLast()
//                    return .none
//                default:
//                    return .none
//                }

            // ============================
            // MemberSetting → Root
            // ============================

//            case let .path(
//                .element(_, action: .memberSetting(action))
//            ):
//                switch action {
//                case let .memberSelected(memberID):
//                    let projection = MemberItemProjection(
//                        domain: MemberDomain(id: memberID, memberName: "")
//                    )
//                    state.path.append(
//                        .memberSettingDetail(
//                            MemberSettingDetailReducer.State(projection: projection)
//                        )
//                    )
//                    return .none
//
//                case .addMemberTapped:
//                    let projection = MemberItemProjection(
//                        domain: MemberDomain(id: UUID(), memberName: "")
//                    )
//                    state.path.append(
//                        .memberSettingDetail(
//                            MemberSettingDetailReducer.State(projection: projection)
//                        )
//                    )
//                    return .none
//                }
            // ============================
            // TagSetting → Root
            // ============================

//            case let .path(
//                .element(_, action: .tagSetting(action))
//            ):
//                switch action {
//
//                case let .tagSelected(tagID):
//                    let projection = TagItemProjection(
//                        domain: TagDomain(id: tagID, tagName: "")
//                    )
//                    state.path.append(
//                        .tagSettingDetail(
//                            TagSettingDetailReducer.State(projection: projection)
//                        )
//                    )
//                    return .none
//
//                case .addTagTapped:
//                    let projection = TagItemProjection(
//                        domain: TagDomain(id: UUID(), tagName: "")
//                    )
//                    state.path.append(
//                        .tagSettingDetail(
//                            TagSettingDetailReducer.State(projection: projection)
//                        )
//                    )
//                    return .none
//                }
            // ============================
            // ActionSetting → Root
            // ============================
            
                
//            case let .path(
//                .element(_, action: .actionSetting(action))
//            ):
//                switch action {

                    
//                case let .actionSelected(actionID):
//                    let projection = ActionItemProjection(
//                        domain: ActionDomain(id: actionID, actionName: "")
//                    )
//                    state.path.append(
//                        .actionSettingDetail(
//                            ActionSettingDetailReducer.State(projection: projection)
//                        )
//                    )
//                    return .none
//
//                case .addActionTapped:
//                    let domain = ActionDomain.init(id: UUID(), actionName: "")
//                    
//                    let projection = ActionItemProjection(domain: domain)
//                    
//                    state.path.append(
//                        .actionSettingDetail(
//                            ActionSettingDetailReducer.State(projection: projection)
//                        )
//                    )
//                    return .none
                
//                case .actionSelected,.addActionTapped,.onAppear, .actionsLoaded, .detail:
//                    return .none
//                }

            // ============================
            // NavigationStack pop
            // ============================

//            case .path(.popFrom):
//                return .none
//
//
//            // ============================
//            // それ以外の path Action はすべて無視
//            // ============================
//
//            case .path:
//                return .none
            default:
                return .none
            }
        }

        .forEach(\.path, action: \.path)
    }
}
