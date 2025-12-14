import SwiftUI

struct EventRowView: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // 日付
            Text(event.eventDate.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
                .foregroundColor(.secondary)

            // イベント名
            Text(event.eventName)
                .font(.headline)

            // 交通手段
            Text("交通手段: \(event.transName)")
                .font(.subheadline)

            // メンバー
            if !event.memberNames.isEmpty {
                Text("メンバー: " + event.memberNames.joined(separator: ", "))
                    .font(.subheadline)
            }

            // タグ
            if !event.tagNames.isEmpty {
                HStack {
                    ForEach(event.tagNames, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }

            // 燃費 + ガソリン単価
            HStack {
                Text("燃費: \(event.kmPerGas, specifier: "%.1f") km/L")
                Text("ガソリン単価: \(event.gasPrice, specifier: "%.0f") 円/L")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}
