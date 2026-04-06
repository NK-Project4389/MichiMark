import SwiftUI

struct MichiTimelineRowView: View {

    let item: MarkLinkItemProjection
    let isFirst: Bool
    let isLast: Bool
    let onMarkTap: () -> Void
    let onLinkTap: () -> Void

    private enum TimelineLayout {
        static let cardHeight: CGFloat = 72
        static let leftColumnWidth: CGFloat = 44
        static let dotRadius: CGFloat = 6
        static let thickLineWidth: CGFloat = 4
        static let thinLineWidth: CGFloat = 1.5
        static let axisX: CGFloat = 20
    }

    var body: some View {
        HStack(spacing: 8) {
            // 左列：タイムラインCanvas
            Canvas { context, size in
                switch item.markLinkType {
                case .mark:
                    drawMarkTimeline(context: context, size: size)
                case .link:
                    drawLinkTimeline(context: context, size: size)
                }
            }
            .frame(width: TimelineLayout.leftColumnWidth, height: TimelineLayout.cardHeight)
            .allowsHitTesting(false)

            // 右列：カードButton
            Button {
                switch item.markLinkType {
                case .mark: onMarkTap()
                case .link: onLinkTap()
                }
            } label: {
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
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Mark行のCanvas描画

    private func drawMarkTimeline(context: GraphicsContext, size: CGSize) {
        let axisX = TimelineLayout.axisX
        let dotRadius = TimelineLayout.dotRadius
        let midY = size.height / 2

        // 上の細線
        if !isFirst {
            var path = Path()
            path.move(to: CGPoint(x: axisX, y: 0))
            path.addLine(to: CGPoint(x: axisX, y: midY - dotRadius))
            context.stroke(path, with: .color(.secondary), lineWidth: TimelineLayout.thinLineWidth)
        }

        // 下の細線
        if !isLast {
            var path = Path()
            path.move(to: CGPoint(x: axisX, y: midY + dotRadius))
            path.addLine(to: CGPoint(x: axisX, y: size.height))
            context.stroke(path, with: .color(.secondary), lineWidth: TimelineLayout.thinLineWidth)
        }

        // ドット
        let dotRect = CGRect(
            x: axisX - dotRadius,
            y: midY - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2
        )
        context.fill(Path(ellipseIn: dotRect), with: .color(.primary))

        // 右向き三角形
        let triangleStartX = axisX + dotRadius + 2
        let triangleEndX = triangleStartX + 14
        var trianglePath = Path()
        trianglePath.move(to: CGPoint(x: triangleStartX, y: midY - 8))
        trianglePath.addLine(to: CGPoint(x: triangleStartX, y: midY + 8))
        trianglePath.addLine(to: CGPoint(x: triangleEndX, y: midY))
        trianglePath.closeSubpath()
        context.fill(trianglePath, with: .color(Color(.systemGray5)))

        // 水平接続線：三角形右端 → size.width
        var hLinePath = Path()
        hLinePath.move(to: CGPoint(x: triangleEndX, y: midY))
        hLinePath.addLine(to: CGPoint(x: size.width, y: midY))
        context.stroke(hLinePath, with: .color(.secondary), lineWidth: TimelineLayout.thinLineWidth)
    }

    // MARK: - Link行のCanvas描画

    private func drawLinkTimeline(context: GraphicsContext, size: CGSize) {
        let axisX = TimelineLayout.axisX
        let midY = size.height / 2

        // 太い縦線（区間線）
        let lineStartY: CGFloat = isFirst ? midY : 0
        let lineEndY: CGFloat = isLast ? midY : size.height
        var verticalPath = Path()
        verticalPath.move(to: CGPoint(x: axisX, y: lineStartY))
        verticalPath.addLine(to: CGPoint(x: axisX, y: lineEndY))
        context.stroke(verticalPath, with: .color(.green), lineWidth: TimelineLayout.thickLineWidth)

        // 水平接続線
        var hLinePath = Path()
        hLinePath.move(to: CGPoint(x: axisX, y: midY))
        hLinePath.addLine(to: CGPoint(x: size.width, y: midY))
        context.stroke(hLinePath, with: .color(.secondary), lineWidth: TimelineLayout.thinLineWidth)
    }
}
