import Foundation

actor InMemoryActionRepository: ActionRepository {

    private var storage: [ActionID: ActionCore] = [:]
    private let schemaVersion = 1

    func fetchAll() async throws -> [ActionDomain] {
        storage.values
            .filter { !$0.isDeleted }
            .map(ActionAdapter.toDomain)
            .sorted { $0.createdAt < $1.createdAt }
    }

    func save(_ action: ActionDomain) async throws {
        let core = ActionAdapter.toCore(
            action,
            schemaVersion: schemaVersion
        )
        storage[action.id] = core
    }

    func update(_ action: ActionDomain) async throws {
        guard var existing = storage[action.id] else {
            throw RepositoryError.notFound
        }

        existing.actionName = action.actionName
        existing.isVisible = action.isVisible
        existing.isDeleted = action.isDeleted
        existing.updatedAt = action.updatedAt

        storage[action.id] = existing
    }
}
