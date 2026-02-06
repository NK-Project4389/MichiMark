import SwiftUI
import ComposableArchitecture

@main
struct MichiMarkApp: App {

    private let store = Store(
        initialState: RootReducer.State(),
        reducer: { RootReducer()._printChanges() }
    )

    // ✅ body の外で 1 回だけ生成
//    private let store = Store(
//        initialState: RootReducer.State(),
//        reducer: { RootReducer() }
//    )

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
