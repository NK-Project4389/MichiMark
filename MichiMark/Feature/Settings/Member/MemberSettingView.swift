import SwiftUI
import ComposableArchitecture

struct MemberSettingView: View {

    @Bindable var store: StoreOf<MemberSettingReducer>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                section(title: "表示") {
                    ForEach(store.members.filter { $0.isVisible }) { member in
                        formRow(member)
                    }
                }

                section(title: "非表示") {
                    ForEach(store.members.filter { !$0.isVisible }) { member in
                        formRow(member)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("メンバー一覧")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.send(.onAppear)
        }
        .safeAreaInset(edge: .bottom) {
            addButton {
                store.send(.addMemberTapped)
            }
        }
        .navigationDestination(
            store: store.scope(
                state: \.$detail,
                action: \.detail
            )
        ) { detailStore in
            MemberSettingDetailView(store: detailStore)
        }
    }

    private func formRow(_ member: MemberItemProjection) -> some View {
        Button {
            store.send(.memberSelected(member.id))
        } label: {
            HStack {
                Image(systemName: "pencil")
                Text(member.memberName)
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
