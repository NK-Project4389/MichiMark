import SwiftUI
import ComposableArchitecture

struct TransSelectView: View {

    @Bindable var store: StoreOf<TransSelectReducer>

    var body: some View {
        WithPerceptionTracking {
            List {
                ForEach(store.items) { item in
                    Button {
                        store.send(.select(item.id))
                    } label: {
                        HStack {
                            Text(item.transName)
                            Spacer()
                            if store.selectedID == item.id {
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
