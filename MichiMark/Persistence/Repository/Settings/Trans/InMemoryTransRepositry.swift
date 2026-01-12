import Foundation

actor InMemoryTransRepository: TransRepository {

    private var storage: [TransID: TransCore] = [:]
    private let schemaVersion = 1

    func fetchAll() async throws -> [TransDomain] {
        storage.values
            .filter { !$0.isDeleted }
            .map(TransAdapter.toDomain)
            .sorted { $0.createdAt < $1.createdAt }
    }

    func save(_ trans: TransDomain) async throws {
        let core = TransAdapter.toCore(
            trans,
            schemaVersion: schemaVersion
        )
        storage[trans.id] = core
    }

    func update(_ trans: TransDomain) async throws {
        guard var existing = storage[trans.id] else {
            throw RepositoryError.notFound
        }

        existing.transName = trans.transName
        existing.kmPerGas = trans.kmPerGas
        existing.meterValue = trans.meterValue
        existing.isVisible = trans.isVisible
        existing.isDeleted = trans.isDeleted
        existing.updatedAt = trans.updatedAt

        storage[trans.id] = existing
    }
}
