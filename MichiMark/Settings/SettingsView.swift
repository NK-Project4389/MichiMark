import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    let store: StoreOf<SettingsReducer>

    var body: some View {
        VStack {
            Text("設定")
                .font(.headline)
            Text("未実装")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .onAppear { store.send(.appeared) }
    }
}
