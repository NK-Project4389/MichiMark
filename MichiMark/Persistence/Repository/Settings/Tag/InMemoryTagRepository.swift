import Foundation

actor InMemoryTagRepository: TagRepository {

    private var storage: [TagID: TagCore] = [:]
    private let schemaVersion = 1
    
    init() {
        Task { [weak self] in
            await self?.seedIfNeeded()
        }
    }

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
    
    private func seedIfNeeded() async {
        guard storage.isEmpty else { return }

        let test1 = TagCore(
            id: TagID(),
            tagName: "Test1",
            isVisible: true,
            isDeleted: false,
            schemaVersion: 1,
            createdAt: Date(),
            updatedAt: Date()
        )

        let test2 = TagCore(
            id: TagID(),
            tagName: "Test1",
            isVisible: true,
            isDeleted: false,
            schemaVersion: 1,
            createdAt: Date(),
            updatedAt: Date()
        )

        storage[test1.id] = test1
        storage[test2.id] = test2
    }
}
