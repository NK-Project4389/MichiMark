import SwiftUI
import ComposableArchitecture

struct ActionSelectView: View {

    let store: StoreOf<ActionSelectReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.items) { item in
                    Button {
                        viewStore.send(.toggle(item.id))
                    } label: {
                        HStack {
                            Text(item.actionName)
                            Spacer()
                            if viewStore.selectedIDs.contains(item.id) {
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
                        viewStore.send(.doneTapped)
                    }
                }
            }
            
            .onAppear {
                viewStore.send(.appeared)
            }

        }
    }
}
