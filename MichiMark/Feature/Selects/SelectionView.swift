import ComposableArchitecture
import SwiftUI

public struct SelectionView<ID: Hashable & Sendable>: View {
    let store: StoreOf<SelectionFeature<ID>>
    @State private var didFinish = false

    public init(store: StoreOf<SelectionFeature<ID>>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(store.items) { item in
                Button {
                    store.send(.itemTapped(item.id))
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                            if let subtitle = item.subtitle {
                                Text(subtitle)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        if store.selected.contains(item.id) {
                                Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
        .navigationTitle("選択")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("完了") {
                    didFinish = true
                    store.send(.doneTapped)
                }
            }
        }
        .onDisappear {
            if !didFinish { store.send(.cancelTapped) }
        }
    }
}
