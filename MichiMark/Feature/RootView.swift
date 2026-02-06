import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<RootReducer>

    init(store: StoreOf<RootReducer>) {
            self.store = store
        }
    var body: some View {
        // NavigationStack は RootView に 1つだけ置く。
        // path は RootReducer.State に保持されるため View 再評価で初期化されず、
        // ルート画面の切替も Stack の identity を変えない。
        NavigationStackStore(
            store.scope(state: \.path, action: \.path)
        ) {
            EventListView(
                store: store.scope(
                    state: \.eventList,
                    action: \.eventList
                )
            )
        } destination: { pathStore in
            switch pathStore.case {
            //EventDetail
            case let .eventDetail(store):EventDetailView(store: store)
            //Settings
            case let .settings(store):SettingsView(store: store)
            case let .transSetting(store):TransSettingView(store: store)
//            case let .transSettingDetail(store):TransSettingDetailView(store: store)
            case let .memberSetting(store):MemberSettingView(store: store)
//            case let .memberSettingDetail(store):MemberSettingDetailView(store: store)
            case let .tagSetting(store):TagSettingView(store: store)
//            case let .tagSettingDetail(store):TagSettingDetailView(store: store)
            case let .actionSetting(store):ActionSettingView(store: store)
            //case let .actionSettingDetail(store):ActionSettingDetailView(store: store)
            // MARK: 選択画面
            case let .transSelect(store):TransSelectView(store: store)
            case let .memberSelect(store):MemberSelectView(store: store)
            case let .tagSelect(store):TagSelectView(store: store)
            case let .actionSelect(store):ActionSelectView(store: store)
            case let .transSelection(store):SelectionView(store: store)
            case let .memberSelection(store):SelectionView(store: store)
            case let .tagSelection(store):SelectionView(store: store)
            case let .actionSelection(store):SelectionView(store: store)
            }
        }
    }
}
