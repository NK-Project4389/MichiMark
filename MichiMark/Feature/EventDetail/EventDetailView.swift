import SwiftUI
import ComposableArchitecture

struct EventDetailView: View {

    @Bindable var store: StoreOf<EventDetailReducer>

    var body: some View {
        VStack(spacing: 0) {
            contentView
            Divider()
            tabBar
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    store.send(.dismissTapped)
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .navigationDestination(
            item: $store.scope(
                state: \.destination,
                action: \.destination
            )
        ) { destinationStore in
            switch destinationStore.case {
            case let .markDetail(store):
                MarkDetailView(store: store)
            case let .linkDetail(store):
                LinkDetailView(store: store)
            case let .paymentDetail(store):
                PaymentDetailView(store: store)
            }
        }
    }
}


private extension EventDetailView {

    @ViewBuilder
    var contentView: some View {
        switch store.core.selectedTab {
        case .basicInfo:
            BasicInfoView(store: store.scope(state: \.core.basicInfo, action: \.core.basicInfo))
        case .michiInfo:
            MichiInfoView(store: store.scope(state: \.core.michiInfo, action: \.core.michiInfo))
        case .paymentInfo:
            PaymentInfoView(store: store.scope(state: \.core.paymentInfo, action: \.core.paymentInfo))
        case .overview:
            OverviewView(store: store.scope(state: \.core.overview, action: \.core.overview))
        }
    }

    var tabBar: some View {
        HStack {
            tabButton(.basicInfo, title: "基本")
            tabButton(.michiInfo, title: "ミチ")
            tabButton(.paymentInfo, title: "支払")
            tabButton(.overview, title: "振り返り")
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    func tabButton(_ tab: EventDetailTab, title: String) -> some View {
        Button {
            store.send(.core(.tabSelected(tab)))
        } label: {
            Text(title)
                .font(.footnote)
                .foregroundColor(store.core.selectedTab == tab ? .primary : .secondary)
                .frame(maxWidth: .infinity)
        }
    }
}
