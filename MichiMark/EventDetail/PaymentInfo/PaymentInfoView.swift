import SwiftUI
import ComposableArchitecture

struct PaymentInfoView: View {
    let store: StoreOf<PaymentInfoReducer>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 12) {
                Text("支払情報")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("未実装（画面遷移確認用）")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
    }
}
