import ComposableArchitecture
import SwiftUI

public struct SelectionView: View {
    let store: StoreOf<SelectionFeature>
    @State private var didFinish = false

    public init(store: StoreOf<SelectionFeature>) {
        self.store = store
    }

    public var body: some View {
        content
            .toolbar {
                if store.isMultipleSelection {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完了") {
                            didFinish = true
                            store.send(.confirmTapped)
                        }
                    }
                }
            }
    }

    private var content: some View {
        List {
            if store.items.isEmpty {
//                Button("新しく追加する") {
//                    didFinish = true
//                    store.send(.addTapped)
//                }
            } else {
                ForEach(store.items) { item in
                    Button {
                        if !store.isMultipleSelection {
                            didFinish = true
                        }
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
                            if isSelected(item.id) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }
            Button("設定画面") {
                didFinish = true
                store.send(.addTapped)
            }
        }
        .navigationTitle("選択")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.send(.appeared) }
    }

    private func isSelected(_ id: UUID) -> Bool {
        switch store.selection {
        case let .single(selected):
            return selected == id
        case let .multiple(selected):
            return selected.contains(id)
        }
    }
}
