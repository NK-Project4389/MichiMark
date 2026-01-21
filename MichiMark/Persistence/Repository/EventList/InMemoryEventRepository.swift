import Foundation

actor InMemoryEventRepository: EventRepositoryProtocol {

    private var storage: [EventID: EventCore] = [:]
    private let schemaVersion = 1

    func fetchAll() async throws -> [EventDomain] {
        storage.values
            .filter { !$0.isDeleted }
            .sorted { $0.createdAt > $1.createdAt }
            .map(EventAdapter.toDomain)
    }

    func fetch(id: EventID) async throws -> EventDomain {
        guard let core = storage[id], !core.isDeleted else {
            throw RepositoryError.notFound
        }
        return EventAdapter.toDomain(core)
    }

    func save(_ event: EventDomain) async throws {
        func save(_ event: EventDomain) async throws {
            var core = EventAdapter.toCore(
                event,
                schemaVersion: schemaVersion
            )
            core.updatedAt = Date()
            core.isDeleted = false
            storage[event.id] = core
        }
    }

    func delete(id: EventID) async throws {
        guard var core = storage[id] else {
            throw RepositoryError.notFound
        }
        core.isDeleted = true
        core.updatedAt = Date()
        storage[id] = core
    }
}
