import SwiftUI
import ComposableArchitecture

struct MemberSelectView: View {

    let store: StoreOf<MemberSelectReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.items) { item in
                    Button {
                        viewStore.send(.toggle(item.id))
                    } label: {
                        HStack {
                            Text(item.memberName)
                            Spacer()
                            if viewStore.selectedIDs.contains(item.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("メンバー選択")
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
