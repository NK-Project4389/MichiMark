import SwiftUI
import ComposableArchitecture

struct EventListView: View {

    let store: StoreOf<EventListReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in

            NavigationStack {

                ZStack {

                    List {
                        Section {
                            ForEach(viewStore.events) { event in
                                EventRowView(event: event)
                                    .onTapGesture {
                                        viewStore.send(.eventTapped(event))
                                    }
                                    .listRowSeparator(.hidden)
                            }
                        } header: {
                            // ===== タイトル行（左：タイトル / 右：設定）=====
                            HStack {
                                Text("イベント一覧")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)

                                Spacer()

                                Button {
                                    viewStore.send(.settingsTapped)
                                } label: {
                                    Image(systemName: "gearshape")
                                        .font(.title3)
                                        .padding(8)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewStore.send(.refresh)
                    }

                }
                // ===== ＋ボタン（右下・スクロール追従）=====
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Spacer()
                        Button {
                            viewStore.send(.addTapped)
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                    }
                    .padding(.trailing)
                    .padding(.bottom, 8)
                }

                .onAppear {
                    viewStore.send(.onAppear)
                }
                .navigationDestination(
                    item: viewStore.binding(
                        get: \.eventDetail,
                        send: { _ in .eventDetail(.backButtonTapped) }
                    )
                ) { _ in
                    EventDetailView(
                        store: store.scope(
                            state: \.eventDetail!,
                            action: \.eventDetail
                        )
                    )
                }
            }
        }
    }
}
