import SwiftUI
import ComposableArchitecture

struct SummaryView: View {
    let store: StoreOf<SummaryReducer>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 12) {
                Text("サマリ情報")
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
