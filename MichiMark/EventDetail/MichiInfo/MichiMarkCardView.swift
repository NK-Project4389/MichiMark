import SwiftUI

struct MichiMarkCardView: View {

    let title: String
    let showsLinkBelow: Bool

    var body: some View {
        VStack(spacing: 0) {

            // ===== カード本体 =====
            VStack {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                    Text(title)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            //.padding(.top, 8)

            // ===== 接続部分（完全密着）=====
            if showsLinkBelow {
                MichiLinkView()
            }
        }
    }
}
