import SwiftUI
import ComposableArchitecture

struct MemberSelectView: View {

    @Bindable var store: StoreOf<MemberSelectReducer>

    var body: some View {
        List {
            ForEach(store.items) { item in
                Button {
                    store.send(.toggle(item.id))
                } label: {
                    HStack {
                        Text(item.memberName)
                        Spacer()
                        if store.selectedIDs.contains(item.id) {
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
                    store.send(.doneTapped)
                }
            }
        }
        .onAppear {
            store.send(.appeared)
        }
    }
}
