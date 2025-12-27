import SwiftUI
import ComposableArchitecture

struct TagSettingDetailView: View {

    let store: StoreOf<TagSettingDetailReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {

                formRow(title: "タグ名") {
                    TextField("入力", text: viewStore.binding(
                        get: \.tagName,
                        send: TagSettingDetailReducer.Action.tagNameChanged
                    ))
                }

                Toggle("非表示", isOn: viewStore.binding(
                    get: { !$0.isVisible },
                    send: { _ in .visibleToggled }
                ))
                .padding()

                Spacer()

                Button("保存") {
                    viewStore.send(.saveTapped)
                }
                .padding()
                .background(Color(.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding()
            }
            .navigationTitle("タグ詳細")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func formRow<Content: View>(
        title: String,
        trailing: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                if let trailing {
                    Text(trailing)
                        .foregroundColor(.secondary)
                }
            }
            content()
        }
        .padding()
        .overlay(Divider(), alignment: .bottom)
    }
}
