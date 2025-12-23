import SwiftUI

struct MichiLinkView: View {

    var body: some View {
        VStack(spacing: 0) {
            Circle()
                .frame(width: 10, height: 10)

            Rectangle()
                .frame(width: 2, height: 40)

            Circle()
                .frame(width: 10, height: 10)
        }
        .foregroundColor(.black)
        //.padding(.vertical, 4)
    }
}
