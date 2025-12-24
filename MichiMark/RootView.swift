import SwiftUI
import ComposableArchitecture

struct RootView: View {
    @Bindable var store: StoreOf<RootReducer>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            EventListView(store: store.scope(state: \.eventList, action: \.eventList))
        } destination: { pathStore in
            switch pathStore.case {
            case let .eventDetail(detailStore):
                EventDetailView(store: detailStore)

            case let .settings(settingsStore):
                SettingsView(store: settingsStore)
                
            case let .markDetail(store):
                MarkDetailView(store: store)

            case let .linkDetail(store):
                LinkDetailView(store: store)
            }
        }
    }
}
