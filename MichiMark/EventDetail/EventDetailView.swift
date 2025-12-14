import SwiftUI
import ComposableArchitecture

struct EventDetailView: View {

    let store: StoreOf<EventDetail>

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
                    store.send(.backButtonTapped)
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}

// MARK: - Content
private extension EventDetailView {

    @ViewBuilder
    var contentView: some View {
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            switch viewStore.state {
            case .basic:
                BasicInfoView(
                    store: store.scope(
                        state: \.basicInfoState,
                        action: \.basicInfo
                    )
                )

            case .michi:
                Text("ミチ情報")

            case .payment:
                Text("支払情報")

            case .summary:
                Text("集計")

            case .route:
                Text("軌跡")
            }
        }
    }
}

// MARK: - TabBar
private extension EventDetailView {

    var tabBar: some View {
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            HStack {
                tabButton("基本情報", .basic, viewStore)
                tabButton("ミチ", .michi, viewStore)
                tabButton("支払", .payment, viewStore)
                tabButton("集計", .summary, viewStore)
                tabButton("軌跡", .route, viewStore)
            }
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
    }


    func tabButton(
        _ title: String,
        _ tab: EventDetailTab,
        _ viewStore: ViewStore<EventDetailTab, EventDetail.Action>
    ) -> some View {
        Button {
            viewStore.send(.tabSelected(tab))
        } label: {
            Text(title)
                .font(.footnote)
                .frame(maxWidth: .infinity)
                .foregroundStyle(
                    viewStore.state == tab ? .primary : .secondary
                )
        }
    }

}
