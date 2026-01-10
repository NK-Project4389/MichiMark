import ComposableArchitecture
import Foundation

@Reducer
struct EventListReducer {

    @ObservableState
    struct State: Equatable {

        /// Event の唯一の情報源（Domain）
        var events: [EventDomain] = Self.sampleEvents

        /// 仮データ（後で Repository 取得に置き換える）
        static let sampleEvents: [EventDomain] = [
            EventDomain(
                id: UUID(),
                eventName: "サンプルイベントA",
                trans: TransDomain(
                    id: UUID(),
                    transName: "車"
                ),
                members: [],
                tags: [],
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date().addingTimeInterval(-86400)
            ),
            EventDomain(
                id: UUID(),
                eventName: "サンプルイベントB",
                trans: TransDomain(
                    id: UUID(),
                    transName: "電車"
                ),
                members: [],
                tags: [],
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }

    enum Action {
        case appeared

        case eventTapped(EventID)
        case addButtonTapped
        case settingsButtonTapped
        case deleteEventTapped(EventID)

        /// 将来の非同期削除用
        case deleteResponse(Result<Void, DeleteError>)
    }

    enum DeleteError: Error, Equatable {
        case failed
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .appeared:
                // 将来：Repository から EventDomain 一覧を取得
                return .none

            case .eventTapped,
                 .addButtonTapped,
                 .settingsButtonTapped,
                 .deleteEventTapped:
                // RootFeature へ通知するのみ
                return .none

            case .deleteResponse:
                return .none
            }
        }
    }
}

extension EventListReducer.State {
    var projection: EventListProjection {
        EventListProjection(
            events: events
                .filter { !$0.isDeleted }
                .map { event in
                    EventSummaryItemProjection(
                        id: event.id,
                        eventName: event.eventName,
                        displayFromDate: event.createdAt.formatted(date: .abbreviated, time: .omitted),
                        displayToDate: ""
                    )
                }
        )
    }
}
