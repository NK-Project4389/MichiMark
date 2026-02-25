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
            case let .markDetail(store):MarkDetailView(store: store)
            case let .linkDetail(store):LinkDetailView(store: store)
            case let .paymentDetail(store):PaymentDetailView(store: store)
            case let .addSheet(store):AddSheetView(store: store)
            case let .datePicker(store):DatePickerView(store: store)
            //Settings
            case let .settings(store):SettingsView(store: store)
            case let .transSetting(store):TransSettingView(store: store)
            case let .transSettingCreate(store):
                TransSettingDetailView(
                    store: store.scope(
                        state: \.detail,
                        action: \.detail
                    )
                )
            case let .memberSetting(store):MemberSettingView(store: store)
            case let .memberSettingCreate(store):
                MemberSettingDetailView(
                    store: store.scope(
                        state: \.detail,
                        action: \.detail
                    )
                )
            case let .tagSetting(store):TagSettingView(store: store)
            case let .tagSettingCreate(store):
                TagSettingDetailView(
                    store: store.scope(
                        state: \.detail,
                        action: \.detail
                    )
                )
            case let .actionSetting(store):ActionSettingView(store: store)
            case let .actionSettingCreate(store):
                ActionSettingDetailView(
                    store: store.scope(
                        state: \.detail,
                        action: \.detail
                    )
                )
            // MARK: 選択画面
            case let .selection(store):SelectionView(store: store)
            }
        }
    }
}
