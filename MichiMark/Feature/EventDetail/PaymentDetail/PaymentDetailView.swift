import SwiftUI
import ComposableArchitecture

struct PaymentDetailView: View {

    @Bindable var store: StoreOf<PaymentDetailReducer>

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            ScrollView {
                VStack(spacing: 0) {
                    row(icon: "yensign.circle", title: "金額", trailing: "円")
                    row(icon: "creditcard", title: "支払者", chevron: true) {
                        store.send(.paymentMemberEditTapped)
                    }
                    row(icon: "person.2", title: "割り勘メンバー", chevron: true) {
                        store.send(.splitMemberEditTapped)
                    }
                    row(icon: "note.text", title: "メモ")
                }
            }

            Button("反映") {
                store.send(.applyButtonTapped)
            }
            .padding()
            .background(Color(.systemGray4))
            .clipShape(Capsule())
            .padding()
        }
        .navigationTitle("その他情報詳細")
        .navigationBarTitleDisplayMode(.inline)
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
