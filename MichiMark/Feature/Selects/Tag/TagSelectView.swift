import SwiftUI
import ComposableArchitecture

struct TagSelectView: View {

    @Bindable var store: StoreOf<TagSelectReducer>

    var body: some View {
        WithPerceptionTracking {
            List {
                ForEach(store.items) { item in
                    Button {
                        store.send(.toggle(item.id))
                    } label: {
                        HStack {
                            Text(item.tagName)
                            Spacer()
                            if store.selectedIDs.contains(item.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("タグ選択")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        store.send(.doneTapped)
                    }
                }
            }
            
            .onAppear {
                store.send(.appeared)
            }

        }
    }
}
