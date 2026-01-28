import SwiftUI

struct MichiLinkCardView: View {

    let title: String
    let displayDistance: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(spacing: 8) {
                Image(systemName: "pencil")
                Text(title)
                    .font(.headline)
            }

            if let distance = displayDistance {
                Text("距離：\(distance)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
        .background(Color.green.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
