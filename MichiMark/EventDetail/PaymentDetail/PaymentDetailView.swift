import SwiftUI
import ComposableArchitecture

struct PaymentDetailView: View {

    let store: StoreOf<PaymentDetailReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .bottomTrailing) {

                ScrollView {
                    VStack(spacing: 0) {
                        row(icon: "yensign.circle", title: "金額", trailing: "円")
                        row(icon: "creditcard", title: "支払者", chevron: true) {
                            viewStore.send(.paymentMemberEditTapped)
                        }
                        row(icon: "person.2", title: "割り勘メンバー", chevron: true) {
                            viewStore.send(.splitMemberEditTapped)
                        }
                        row(icon: "note.text", title: "メモ")
                    }
                }

                Button("保存") {
                    viewStore.send(.saveTapped)
                }
                .padding()
                .background(Color(.systemGray4))
                .clipShape(Capsule())
                .padding()
            }
            .navigationTitle("その他情報詳細")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func row(
        icon: String,
        title: String,
        trailing: String? = nil,
        chevron: Bool = false,
        onTap: (() -> Void)? = nil
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            Text(title)
            Spacer()
            if let trailing {
                Text(trailing)
            }
            if chevron {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
        .overlay(Divider(), alignment: .bottom)
    }
}
