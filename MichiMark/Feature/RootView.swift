import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<RootReducer>

    var body: some View {
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
            }
        }
    }
}
