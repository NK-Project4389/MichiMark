import SwiftUI
import ComposableArchitecture

struct TransSettingView: View {

    let store: StoreOf<TransSettingReducer>

    var body: some View {
        WithViewStore(store, observe: \.transes) { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    section(title: "表示") {
                        ForEach(viewStore.state.filter { $0.isVisible }) { trans in
                            formRow(trans)
                        }
                    }

                    section(title: "非表示") {
                        ForEach(viewStore.state.filter { !$0.isVisible }) { trans in
                            formRow(trans)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("タグ一覧")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                store.send(.onAppear)
            }
            .safeAreaInset(edge: .bottom) {
                addButton {
                    store.send(.addTransTapped)
                }
            }
            .navigationDestination(
                store: store.scope(
                    state: \.$detail,
                    action: TransSettingReducer.Action.detail
                )
            ) { detailStore in
                TransSettingDetailView(store: detailStore)
            }
        }
    }

    private func formRow(_ trans: TransItemProjection) -> some View {
        Button {
            store.send(.transSelected(trans.id))
        } label: {
            HStack {
                Image(systemName: "pencil")
                Text(trans.transName)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
    }

    private func addButton(action: @escaping () -> Void) -> some View {
        HStack {
            Spacer()
            Button(action: action) {
                Image(systemName: "plus")
                    .font(.title2)
                    .frame(width: 56, height: 56)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
        .padding()
    }
}
