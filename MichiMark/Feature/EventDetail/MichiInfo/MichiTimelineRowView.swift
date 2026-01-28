import SwiftUI
import ComposableArchitecture

struct MichiTimelineRowView: View {

    let item: MarkLinkItemProjection
    let isFirst: Bool
    let isLast: Bool
    let onMarkTap: () -> Void
    let onLinkTap: () -> Void

    var body: some View {
        // 右：カード
        Button {
            switch item.markLinkType {
            case .mark: onMarkTap()
            case .link: onLinkTap()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                switch item.markLinkType {
                case .mark:
                    MichiMarkCardView(
                        title: item.markLinkName,
                        displayMeter: item.displayMeterValue,
                        memo: item.memo ?? ""
                    )

                case .link:
                    MichiLinkCardView(
                        title: item.markLinkName,
                        displayDistance: item.displayDistanceValue
                    )
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)   // ★ 見た目を壊さない
    }
}
