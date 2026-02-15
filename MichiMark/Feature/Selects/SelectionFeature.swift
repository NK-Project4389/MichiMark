// 「この Feature は UI と選択状態管理のみを責務とする」
import ComposableArchitecture
import SwiftUI

@Reducer
public struct SelectionFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        public var useCase: SelectionUseCase
        public var items: IdentifiedArrayOf<SelectionItem>
        public var selection: SelectionValue

        public init(
            useCase: SelectionUseCase,
            items: IdentifiedArrayOf<SelectionItem>,
            selection: SelectionValue
        ) {
            self.useCase = useCase
            self.items = items
            self.selection = selection
        }

        public var isMultipleSelection: Bool {
            if case .multiple = selection { return true }
            return false
        }
    }

    public enum Action: Sendable, Equatable {
        case appeared
        case itemTapped(UUID)
        case confirmTapped
        case addTapped
        case reloadAfterCreate(createdID: UUID)
        case autoSelectAndDismiss(createdID: UUID)
        case reloadResponse([SelectionItem], createdID: UUID)
        case reloadFailed(createdID: UUID)
        case delegate(Delegate)

        public enum Delegate: Sendable, Equatable {
            case completed(useCase: SelectionUseCase, ids: [UUID], names: [UUID: String])
            case requestCreate(useCase: SelectionUseCase)
        }
    }

    public init() {}

    @Dependency(\.transRepository) var transRepository
    @Dependency(\.memberRepository) var memberRepository
    @Dependency(\.tagRepository) var tagRepository
    @Dependency(\.actionRepository) var actionRepository

    private enum CancelID { case reloadAfterCreate }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appeared:
                return .none

            case let .itemTapped(id):
                switch state.selection {
                case .single:
                    state.selection = .single(id)
                    let names = selectionNames(
                        ids: [id],
                        items: state.items
                    )
                    return .send(
                        .delegate(
                            .completed(useCase: state.useCase, ids: [id], names: names)
                        )
                    )

                case let .multiple(selected):
                    var updated = selected
                    if updated.contains(id) {
                        updated.remove(id)
                    } else {
                        updated.insert(id)
                    }
                    state.selection = .multiple(updated)
                    return .none
                }

            case .confirmTapped:
                guard case let .multiple(selected) = state.selection else {
                    return .none
                }
                let ordered = state.items.compactMap { item in
                    selected.contains(item.id) ? item.id : nil
                }
                let names = selectionNames(
                    ids: ordered,
                    items: state.items
                )
                return .send(
                    .delegate(
                        .completed(useCase: state.useCase, ids: ordered, names: names)
                    )
                )

            case .addTapped:
                return .send(.delegate(.requestCreate(useCase: state.useCase)))

            case let .reloadAfterCreate(createdID):
                let useCase = state.useCase
                return .run { send in
                    do {
                        let items = try await fetchSelectionItems(useCase: useCase)
                        await send(.reloadResponse(items, createdID: createdID))
                    } catch {
                        await send(.reloadFailed(createdID: createdID))
                    }
                }
                .cancellable(id: CancelID.reloadAfterCreate, cancelInFlight: true)

            case let .autoSelectAndDismiss(createdID):
                switch state.selection {
                case .single:
                    state.selection = .single(createdID)
                    let names = selectionNames(
                        ids: [createdID],
                        items: state.items
                    )
                    return .send(
                        .delegate(
                            .completed(useCase: state.useCase, ids: [createdID], names: names)
                        )
                    )
                case let .multiple(selected):
                    var updated = selected
                    updated.insert(createdID)
                    state.selection = .multiple(updated)
                    return .send(.confirmTapped)
                }

            case let .reloadResponse(items, createdID):
                state.items = IdentifiedArray(uniqueElements: items)
                let createdItem = items.first { $0.id == createdID }
                switch state.selection {
                case .single:
                    if createdItem != nil {
                        state.selection = .single(createdID)
                    }
                case let .multiple(selected):
                    var updated = selected
                    if createdItem != nil {
                        updated.insert(createdID)
                    }
                    state.selection = .multiple(updated)
                }
                if case .single = state.selection,
                   let createdItem {
                    return .send(
                        .delegate(
                            .completed(
                                useCase: state.useCase,
                                ids: [createdID],
                                names: [createdID: createdItem.title]
                            )
                        )
                    )
                }
                return .none

            case .reloadFailed:
                return .none

            case let .delegate(delegateAction):
                if case .completed = delegateAction {
                    return .cancel(id: CancelID.reloadAfterCreate)
                }
                return .none
            }
        }
    }

    private func selectionNames(
        ids: [UUID],
        items: IdentifiedArrayOf<SelectionItem>
    ) -> [UUID: String] {
        let idSet = Set(ids)
        return Dictionary(
            uniqueKeysWithValues: items
                .filter { idSet.contains($0.id) }
                .map { ($0.id, $0.title) }
        )
    }

    private func fetchSelectionItems(useCase: SelectionUseCase) async throws -> [SelectionItem] {
        switch useCase {
        case .eventTrans:
            let domains = try await transRepository.fetchAll()
            let projections = TransProjectionAdapter()
                .adaptList(transes: domains)
                .filter { $0.isVisible }
            return projections.map { projection in
                let subtitleParts = [
                    projection.displayKmPerGas.isEmpty ? nil : "燃費 \(projection.displayKmPerGas)",
                    projection.displayMeterValue.isEmpty ? nil : "メーター \(projection.displayMeterValue)"
                ].compactMap { $0 }
                let subtitle = subtitleParts.isEmpty ? nil : subtitleParts.joined(separator: " / ")
                return SelectionItem(
                    id: projection.id,
                    title: projection.transName,
                    subtitle: subtitle
                )
            }

        case .eventMembers, .gasPayMember, .markMembers, .linkMembers, .payMember, .splitMembers:
            let domains = try await memberRepository.fetchAll()
            let projections = MemberProjectionAdapter()
                .adaptList(members: domains)
                .filter { $0.isVisible }
            return projections.map { projection in
                let subtitle = projection.mailAddress?.isEmpty == false
                    ? projection.mailAddress
                    : nil
                return SelectionItem(
                    id: projection.id,
                    title: projection.memberName,
                    subtitle: subtitle
                )
            }

        case .eventTags:
            let domains = try await tagRepository.fetchAll()
            let projections = TagProjectionAdapter()
                .adaptList(tags: domains)
                .filter { $0.isVisible }
            return projections.map { projection in
                SelectionItem(
                    id: projection.id,
                    title: projection.tagName,
                    subtitle: nil
                )
            }

        case .markActions, .linkActions:
            let domains = try await actionRepository.fetchAll()
            let projections = ActionProjectionAdapter()
                .adaptList(actions: domains)
                .filter { $0.isVisible }
            return projections.map { projection in
                SelectionItem(
                    id: projection.id,
                    title: projection.actionName,
                    subtitle: nil
                )
            }
        }
    }
}
