import SwiftUI
import ComposableArchitecture

struct OverviewView: View {
    let store: StoreOf<OverviewReducer>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 12) {
                Text("振り返り")
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
