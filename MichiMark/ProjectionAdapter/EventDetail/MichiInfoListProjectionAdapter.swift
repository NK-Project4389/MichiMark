import Foundation

struct MichiInfoListProjectionAdapter {

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()

    func adapt(markLinks: [MarkLinkDomain]) -> MichiInfoListProjection {

        let items = markLinks
            .filter { !$0.isDeleted }
            .sorted { $0.markLinkSeq < $1.markLinkSeq }
            .map { adaptItem($0) }

        return MichiInfoListProjection(items: items)
    }

    func adaptItem(_ domain: MarkLinkDomain) -> MarkLinkItemProjection {

        let title = domain.markLinkName
            ?? (domain.markLinkType == .mark ? "マーク" : "リンク")

        let distanceText: String? = {
            if domain.markLinkType == .link,
               let value = domain.distanceValue {
                return "\(value) km"
            }
            return nil
        }()

        let actions = domain.actions
            .filter { !$0.isDeleted && $0.isVisible }
            .map { ActionItemProjection(domain: $0) }

        return MarkLinkItemProjection(
            id: domain.id,
            title: title,
            displayDate: dateFormatter.string(from: domain.markLinkDate),
            displayDistance: distanceText,
            actions: actions,
            isFuel: domain.isFuel
        )
    }
}
