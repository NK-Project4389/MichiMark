import SwiftUI

import SwiftUI

struct MichiMarkCardView: View {

    let title: String
    let displayMeter: String?
    let memo: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(spacing: 8) {
                Image(systemName: "pencil")
                Text(title)
                    .font(.headline)
            }

            if let meter = displayMeter {
                Text("メーター：\(meter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !memo.isEmpty {
                Text(memo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

