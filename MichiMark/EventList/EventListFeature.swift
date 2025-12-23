import ComposableArchitecture
import Foundation

@Reducer
struct EventListReducer {

    @ObservableState
    struct State: Equatable {
        var events: [EventSummary] = [
            .init(id: UUID(), eventDate: Date(), eventName: "サンプルイベントA"),
            .init(id: UUID(), eventDate: Date().addingTimeInterval(-86400), eventName: "サンプルイベントB"),
        ]
    }

    enum Action {
        case appeared

        case eventTapped(EventID)
        case addButtonTapped
        case settingsButtonTapped
        case deleteEventTapped(EventID)

        // 非同期は今回は実装しないが、設計書に合わせて形だけ用意
        case deleteResponse(Result<Void, DeleteError>)
    }

    enum DeleteError: Error, Equatable {
        case failed
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appeared:
                return .none
            case .eventTapped, .addButtonTapped, .settingsButtonTapped, .deleteEventTapped:
                // Rootへ通知するだけ（Rootが処理）
                return .none
            case .deleteResponse:
                return .none
            }
        }
    }
}
