import SwiftUI
import ComposableArchitecture

struct TagSettingView: View {

    let store: StoreOf<TagSettingReducer>

    var body: some View {
        WithViewStore(store, observe: \.tags) { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    section(title: "表示") {
                        ForEach(viewStore.state.filter { $0.isVisible }) { tag in
                            tagRow(tag)
                        }
                    }

                    section(title: "非表示") {
                        ForEach(viewStore.state.filter { !$0.isVisible }) { tag in
                            tagRow(tag)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("タグ一覧")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                addButton {
                    store.send(.addTagTapped)
                }
            }
        }
    }

    private func tagRow(_ tag: TagItemProjection) -> some View {
        Button {
            store.send(.tagSelected(tag.id))
        } label: {
            HStack {
                Image(systemName: "pencil")
                Text(tag.tagName)
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
