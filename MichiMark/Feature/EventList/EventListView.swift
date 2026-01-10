import SwiftUI
import ComposableArchitecture

struct EventListView: View {

    @Bindable var store: StoreOf<EventListReducer>

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(store.projection.events) { item in
                    Button {
                        store.send(.eventTapped(item.id))
                    } label: {
                        eventRow(item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .navigationTitle("イベント")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            addButton {
                store.send(.addButtonTapped)
            }
        }
        .onAppear {
            store.send(.appeared)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.settingsButtonTapped)
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
}

private extension EventListView {

    func eventRow(_ item: EventSummaryItemProjection) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.eventName)
                    .font(.headline)

                Text(item.displayFromDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    func addButton(action: @escaping () -> Void) -> some View {
        HStack {
            Spacer()
            Button(action: action) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
        .padding()
    }
}
