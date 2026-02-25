import SwiftUI
import ComposableArchitecture

struct ActionSelectView: View {

    @Bindable var store: StoreOf<ActionSelectReducer>

    var body: some View {
        List {
            ForEach(store.items) { item in
                Button {
                    store.send(.toggle(item.id))
                } label: {
                    HStack {
                        Text(item.actionName)
                        Spacer()
                        if store.selectedIDs.contains(item.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
        .navigationTitle("行動選択")
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
