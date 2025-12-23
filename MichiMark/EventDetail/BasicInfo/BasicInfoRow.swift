import SwiftUI

/// 基本情報画面用の1行表示コンポーネント
/// ※ 見た目専用（タップ・遷移・状態管理は持たない）
struct BasicInfoRow: View {

    let icon: String
    let title: String
    let value: String?
    let unit: String?
    let showsChevron: Bool

    init(
        icon: String,
        title: String,
        value: String? = nil,
        unit: String? = nil,
        showsChevron: Bool = false
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.unit = unit
        self.showsChevron = showsChevron
    }

    var body: some View {
        HStack(spacing: 12) {

            // アイコン
            Image(systemName: icon)
                .font(.body)
                .frame(width: 24)
                .foregroundColor(.primary)

            // タイトル
            Text(title)
                .font(.body)

            Spacer()

            // 値
            if let value, !value.isEmpty {
                Text(value)
                    .foregroundColor(.secondary)
            }

            // 単位
            if let unit {
                Text(unit)
                    .foregroundColor(.secondary)
            }

            // Chevron
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .overlay(
            Divider(), alignment: .bottom
        )
    }
}
