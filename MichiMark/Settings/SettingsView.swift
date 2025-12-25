import SwiftUI
import ComposableArchitecture

struct SettingsView: View {

    let store: StoreOf<SettingsReducer>

    var body: some View {
        List {
            settingRow(
                icon: "car",
                title: "交通手段",
                action: { store.send(.transSettingSelected) }
            )

            settingRow(
                icon: "person",
                title: "メンバー",
                action: { store.send(.memberSettingSelected) }
            )

            settingRow(
                icon: "tag",
                title: "タグ",
                action: { store.send(.tagSettingSelected) }
            )

            settingRow(
                icon: "figure.walk",
                title: "行動",
                action: { store.send(.actionSettingSelected) }
            )
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func settingRow(
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
}
