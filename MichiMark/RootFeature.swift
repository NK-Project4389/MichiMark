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
    struct State: Equatable {
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

    @Reducer(state: .equatable)
    enum Path {
        case eventDetail(EventDetailReducer)
        case settings(SettingsReducer)
        case transSetting(TransSettingReducer)
        case transSettingDetail(TransSettingDetailReducer)
        case memberSetting(MemberSettingReducer)
        case memberSettingDetail(MemberSettingDetailReducer)
        case tagSetting(TagSettingReducer)
        case tagSettingDetail(TagSettingDetailReducer)
        case actionSetting(ActionSettingReducer)
        case actionSettingDetail(ActionSettingDetailReducer)
        case markDetail(MarkDetailReducer)
        case linkDetail(LinkDetailReducer)
        case paymentDetail(PaymentDetailReducer)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.eventList, action: \.eventList) { EventListReducer() }

        Reduce { state, action in
            switch action {

            // ============================
            // EventList → Root（Navigation）
            // ============================

            case let .eventList(.eventTapped(eventID)):
                state.path.append(
                    .eventDetail(EventDetailReducer.State(eventID: eventID))
                )
                return .none

            case .eventList(.settingsButtonTapped):
                state.path.append(.settings(SettingsReducer.State()))
                return .none

            case .eventList(.addButtonTapped):
                let new = EventSummary(
                    id: UUID(),
                    eventDate: Date(),
                    eventName: "New Event"
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

            case let .path(
                .element(
                    id: elementID,
                    action: .eventDetail(.delegate(.openMarkDetail(markLinkID)))
                )
            ):
                guard
                    let eventDetailState = state.path[id: elementID]?.eventDetail
                else { return .none }

                state.path.append(
                    .markDetail(
                        MarkDetailReducer.State(
                            eventID: eventDetailState.eventID,
                            markLinkID: markLinkID
                        )
                    )
                )
                return .none


            case let .path(
                .element(
                    id: elementID,
                    action: .eventDetail(.delegate(.openLinkDetail(markLinkID)))
                )
            ):
                guard
                    let eventDetailState = state.path[id: elementID]?.eventDetail
                else { return .none }

                state.path.append(
                    .linkDetail(
                        LinkDetailReducer.State(
                            eventID: eventDetailState.eventID,
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
                    action: .eventDetail(.delegate(.openPaymentDetail(paymentID)))
                )
            ):
                guard
                    let eventDetailState = state.path[id: elementID]?.eventDetail
                else { return .none }

                state.path.append(
                    .paymentDetail(
                        PaymentDetailReducer.State(
                            eventID: eventDetailState.eventID,
                            paymentID: paymentID
                        )
                    )
                )
                return .none

                
            // ============================
            // EventDetail → Root（dismiss）
            // ============================

            case .path(
              .element(id: _, action: .eventDetail(.delegate(.dismiss)))
            ):
              print("✅ Root received dismiss delegate")
              if !state.path.isEmpty {
                state.path.removeLast()
              } else {
                print("⚠️ path is empty")
              }
              return .none
            
            // ============================
            // Settings → Root（Navigation）
            // ============================

            case let .path(
                .element(id: _, action: .settings(action))
            ):
                switch action {

                case .transSettingSelected:
                    state.path.append(.transSetting(TransSettingReducer.State(
                        transes: [
                            TransInfo(id: UUID(),transName: "自動車",isVisible: true),
                            TransInfo(id: UUID(),transName: "自転車",isVisible: true),
                            TransInfo(id: UUID(),transName: "電車",isVisible: false),
                        ]
                    )))
                    return .none

                case .memberSettingSelected:
                    state.path.append(.memberSetting(MemberSettingReducer.State(
                        members: [
                            MemberInfo(id: UUID(),memberName: "黒崎",isVisible: true),
                            MemberInfo(id: UUID(),memberName: "森",isVisible: true),
                        ]
                    )))
                    return .none

                case .tagSettingSelected:
                    state.path.append(.tagSetting(TagSettingReducer.State(
                        tags: [
                            TagInfo(id: UUID(),tagName: "旅行",isVisible: true),
                            TagInfo(id: UUID(),tagName: "仕事",isVisible: true),
                        ]
                    )))
                    return .none

                case .actionSettingSelected:
                    state.path.append(.actionSetting(ActionSettingReducer.State(
                        actions: [
                            ActionInfo(id: UUID(),actionName: "休憩",isVisible: true),
                            ActionInfo(id: UUID(),actionName: "レジャー",isVisible: true),
                        ]
                    )))
                    return .none

                case .backTapped:
                    state.path.popLast()
                    return .none
                }
            // ============================
            // TransSetting → Root
            // ============================

            case let .path(
                .element(_, action: .transSetting(action))
            ):
                switch action {

                case let .transSelected(transID):
                    state.path.append(.transSettingDetail(
                        TransSettingDetailReducer.State(transID: transID)
                    ))
                    return .none

                case .addTransTapped:
                    state.path.append(.transSettingDetail(
                        TransSettingDetailReducer.State(transID: UUID())
                    ))
                    return .none
                }
            // ============================
            // TransSettingDetail → Root
            // ============================

            case let .path(
                .element(_, action: .transSettingDetail(action))
            ):
                switch action {
                case .saveTapped, .backTapped:
                    state.path.popLast()
                    return .none
                default:
                    return .none
                }

            // ============================
            // MemberSetting → Root
            // ============================

            case let .path(
                .element(_, action: .memberSetting(action))
            ):
                switch action {

                case let .memberSelected(MemberID):
                    state.path.append(.memberSettingDetail(
                        MemberSettingDetailReducer.State(memberID: MemberID)
                    ))
                    return .none

                case .addMemberTapped:
                    state.path.append(.memberSettingDetail(
                        MemberSettingDetailReducer.State(memberID: UUID())
                    ))
                    return .none
                }
            // ============================
            // TagSetting → Root
            // ============================

            case let .path(
                .element(_, action: .tagSetting(action))
            ):
                switch action {

                case let .tagSelected(TagID):
                    state.path.append(.tagSettingDetail(
                        TagSettingDetailReducer.State(tagID: TagID)
                    ))
                    return .none

                case .addTagTapped:
                    state.path.append(.tagSettingDetail(
                        TagSettingDetailReducer.State(tagID: UUID())
                    ))
                    return .none
                }
            // ============================
            // TagSetting → Root
            // ============================

            case let .path(
                .element(_, action: .actionSetting(action))
            ):
                switch action {

                case let .actionSelected(ActionID):
                    state.path.append(.actionSettingDetail(
                        ActionSettingDetailReducer.State(actionID: ActionID)
                    ))
                    return .none

                case .addActionTapped:
                    state.path.append(.actionSettingDetail(
                        ActionSettingDetailReducer.State(actionID: UUID())
                    ))
                    return .none
                }// ============================
            // NavigationStack pop
            // ============================

            case .path(.popFrom):
                return .none


            // ============================
            // それ以外の path Action はすべて無視
            // ============================

            case .path:
                return .none
            }
        }

        .forEach(\.path, action: \.path)
    }
}
