import SwiftUI
import ComposableArchitecture

private struct ViewState: Equatable {
    let draft: MemberDraft
    let isSaving: Bool

    init(state: MemberSettingDetailReducer.State) {
        self.draft = state.draft
        self.isSaving = state.isSaving
    }
}

struct MemberSettingDetailView: View {

    let store: StoreOf<MemberSettingDetailReducer>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ZStack {
                VStack(spacing: 0) {
                    formRow(title: "メンバー名") {

                        TextField(
                            "入力",
                            text: viewStore.binding(
                                get: { $0.draft.memberName },
                                send: MemberSettingDetailReducer.Action.memberNameChanged
                            )
                        )

                        Toggle(
                            "非表示",
                            isOn: viewStore.binding(
                                get: { !$0.draft.isVisible },
                                send: { _ in .visibleToggled }
                            )
                        )
                        .padding()
                    }
                }

                if viewStore.isSaving {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()

                    ProgressView("保存中...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                }
            }
            .disabled(viewStore.isSaving)
            .navigationTitle("メンバー詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        viewStore.send(.saveTapped)
                    }
                    .disabled(viewStore.isSaving)
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
