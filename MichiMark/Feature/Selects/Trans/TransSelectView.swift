import SwiftUI
import ComposableArchitecture

struct TransSelectView: View {

    let store: StoreOf<TransSelectReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.items) { item in
                    Button {
                        viewStore.send(.select(item.id))
                    } label: {
                        HStack {
                            Text(item.transName)
                            Spacer()
                            if viewStore.selectedID == item.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("交通手段選択")
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
