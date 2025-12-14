import Foundation
import ComposableArchitecture

@ObservableState
struct EventListState: Equatable {
    var events: [Event] = []
    var isLoading: Bool = false

    // 子画面（EventDetail）への NavigationState は後で追加予定
    // 追加
    var eventDetail: EventDetail.State?
}

