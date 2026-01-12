import Foundation

actor InMemoryTagRepository: TagRepository {

    private var storage: [TagID: TagCore] = [:]
    private let schemaVersion = 1

    func fetchAll() async throws -> [TagDomain] {
        storage.values
            .filter { !$0.isDeleted }
            .map(TagAdapter.toDomain)
            .sorted { $0.createdAt < $1.createdAt }
    }

    func save(_ tag: TagDomain) async throws {
        let core = TagAdapter.toCore(
            tag,
            schemaVersion: schemaVersion
        )
        storage[tag.id] = core
    }

    func update(_ tag: TagDomain) async throws {
        guard var existing = storage[tag.id] else {
            throw RepositoryError.notFound
        }

        existing.tagName = tag.tagName
        existing.isVisible = tag.isVisible
        existing.isDeleted = tag.isDeleted
        existing.updatedAt = tag.updatedAt

        storage[tag.id] = existing
    }
}
