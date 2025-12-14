import SwiftUI
import ComposableArchitecture

@main
struct MichiMarkApp: App {
    var body: some Scene {
        WindowGroup {
            EventListView(
                store: Store(
                    initialState: EventListReducer.State(),
                    reducer: {
                        EventListReducer()
                    }
                )
            )
        }
    }
}
