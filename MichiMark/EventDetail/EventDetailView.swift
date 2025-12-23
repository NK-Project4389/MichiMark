import SwiftUI
import ComposableArchitecture

struct EventDetailView: View {

    let store: StoreOf<EventDetailReducer>

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
    }
}


private extension EventDetailView {

    @ViewBuilder
    var contentView: some View {
        WithPerceptionTracking {
            switch store.selectedTab {
            case .basicInfo:
                BasicInfoView(store: store.scope(state: \.basicInfo, action: \.basicInfo))
            case .michiInfo:
                MichiInfoView(store: store.scope(state: \.michiInfo, action: \.michiInfo))
            case .paymentInfo:
                PaymentInfoView(store: store.scope(state: \.paymentInfo, action: \.paymentInfo))
            case .summaryInfo:
                SummaryView(store: store.scope(state: \.summaryInfo, action: \.summaryInfo))
            case .routeInfo:
                RouteInfoView(store: store.scope(state: \.routeInfo, action: \.routeInfo))
            }
        }
    }

    var tabBar: some View {
        HStack {
            tabButton(.basicInfo, title: "基本")
            tabButton(.michiInfo, title: "ミチ")
            tabButton(.paymentInfo, title: "支払")
            tabButton(.summaryInfo, title: "要約")
            tabButton(.routeInfo, title: "経路")
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    func tabButton(_ tab: EventDetailTab, title: String) -> some View {
        Button {
            store.send(.tabSelected(tab))
        } label: {
            Text(title)
                .font(.footnote)
                .foregroundColor(store.selectedTab == tab ? .primary : .secondary)
                .frame(maxWidth: .infinity)
        }
    }
}
