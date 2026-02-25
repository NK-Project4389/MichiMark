import SwiftUI
import ComposableArchitecture

struct MemberSettingDetailView: View {

    @Bindable var store: StoreOf<MemberSettingDetailReducer>

    var body: some View {
        WithPerceptionTracking {
            ZStack {
                VStack(spacing: 0) {
                    formRow(title: "メンバー名") {

                        TextField(
                            "入力",
                            text: $store.draft.memberName
                        )

                        Toggle(
                            "非表示",
                            isOn: $store.draft.isHidden
                        )
                        .padding()
                    }
                }

                if store.isSaving {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()

                    ProgressView("保存中...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                }
            }
            .disabled(store.isSaving)
            .navigationTitle("メンバー詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        store.send(.saveTapped)
                    }
                    .disabled(store.isSaving)
                }
            }
        }
        .alert(
            store: store.scope(
                state: \.$alert,
                action: MemberSettingDetailReducer.Action.alert
            )
        )
        
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
