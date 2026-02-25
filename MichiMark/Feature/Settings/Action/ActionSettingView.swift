import SwiftUI
import ComposableArchitecture

struct ActionSettingView: View {

    @Bindable var store: StoreOf<ActionSettingReducer>

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    section(title: "表示") {
                        ForEach(store.actions.filter { $0.isVisible }) { action in
                            actionRow(action)
                        }
                    }

                    section(title: "非表示") {
                        ForEach(store.actions.filter { !$0.isVisible }) { action in
                            actionRow(action)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("行動一覧")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                store.send(.onAppear)
            }
            .safeAreaInset(edge: .bottom) {
                addButton {
                    store.send(.addActionTapped)
                }
            }
            // ⭐ Detail 画面遷移（PresentationState）
            .navigationDestination(
                store: store.scope(
                    state: \.$detail,
                    action: ActionSettingReducer.Action.detail
                )
            ) { detailStore in
                ActionSettingDetailView(store: detailStore)
            }
        }
    }

    private func actionRow(_ action: ActionItemProjection) -> some View {
        Button {
            store.send(.actionSelected(action.id))
        } label: {
            HStack {
                Image(systemName: "pencil")
                Text(action.actionName)
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
