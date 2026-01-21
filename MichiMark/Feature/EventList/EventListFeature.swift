import ComposableArchitecture
import Foundation

@Reducer
struct EventListReducer {

    @ObservableState
    struct State: Equatable {
        var events: [EventDomain] = []
    }

    @Dependency(\.eventRepositoryProtocol) var eventRepositoryProtocol

    enum Action {
        case appeared
        
        case eventsLoaded([EventDomain])

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
                return .run { send in
                    let events = try await eventRepositoryProtocol.fetchAll()
                    await send(.eventsLoaded(events))
                }

            case let .deleteEventTapped(id):
                return .run { _ in
                    try await eventRepositoryProtocol.delete(id: id)
                }
            case .eventTapped,
                    .eventsLoaded,
                 .addButtonTapped,
                 .settingsButtonTapped:
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
            events: events.map { event in
                let date = event.markLinks?.first?.markLinkDate ?? Date()

                return EventSummaryItemProjection(
                    id: event.id,
                    eventName: event.eventName,
                    displayFromDate: date.formatted(date: .abbreviated, time: .omitted),
                    displayToDate: ""
                )
            }
        )
    }
}

