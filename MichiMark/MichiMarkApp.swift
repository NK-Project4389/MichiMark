import SwiftUI
import ComposableArchitecture

@main
struct MichiMarkApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(
                    initialState: RootReducer.State(),
                    reducer: {
                        RootReducer()
                    }
                )
            )
        }
    }
}
