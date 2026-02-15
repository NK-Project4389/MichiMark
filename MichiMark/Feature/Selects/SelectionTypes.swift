import ComposableArchitecture
import Foundation

public enum SelectionUseCase: Equatable, Sendable {

    // BasicInfo
    case eventTrans
    case eventMembers
    case eventTags
    case gasPayMember

    // MichiInfoMark
    case markMembers
    case markActions

    // MichiInfoLink
    case linkMembers
    case linkActions

    // Payment
    case payMember
    case splitMembers
}

public enum SelectionKind: Equatable, Sendable {
    case member
    case tag
    case action
    case trans
}

public enum SelectionValue: Equatable, Sendable {
    case single(UUID?)
    case multiple(Set<UUID>)
}

public struct SelectionItem: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let subtitle: String?

    public init(id: UUID, title: String, subtitle: String?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}

enum SelectionFactory {
    static func make(
        useCase: SelectionUseCase,
        items: [SelectionItem],
        preselectedIDs: Set<UUID>
    ) -> SelectionFeature.State {
        let itemIDSet = Set(items.map(\.id))
        let validIDs = preselectedIDs.intersection(itemIDSet)

        let selection: SelectionValue
        switch useCase {
        case .eventTrans, .gasPayMember, .payMember:
            let firstID = items.first { validIDs.contains($0.id) }?.id
            selection = .single(firstID)

        case .eventMembers, .eventTags, .markActions, .linkActions, .markMembers, .linkMembers, .splitMembers:
            selection = .multiple(validIDs)
        }

        return SelectionFeature.State(
            useCase: useCase,
            items: IdentifiedArray(uniqueElements: items),
            selection: selection
        )
    }
}
