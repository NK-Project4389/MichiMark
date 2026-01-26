import Foundation

actor InMemoryMemberRepository: MemberRepository {
    
    private var storage: [MemberID: MemberCore] = [:]
    private let schemaVersion = 1
    
    init() {
        Task { [weak self] in
            await self?.seedIfNeeded()
        }
    }
    
    func fetchAll() async throws -> [MemberDomain] {
        storage.values
            .filter { !$0.isDeleted }
            .map(MemberAdapter.toDomain)
            .sorted { $0.createdAt < $1.createdAt }
    }
    
    func save(_ member: MemberDomain) async throws {
        let core = MemberAdapter.toCore(
            member,
            schemaVersion: schemaVersion
        )
        storage[member.id] = core
    }
    
    func update(_ member: MemberDomain) async throws {
        guard var existing = storage[member.id] else {
            throw RepositoryError.notFound
        }
        
        existing.memberName = member.memberName
        existing.mailAddress = member.mailAddress
        existing.isVisible = member.isVisible
        existing.isDeleted = member.isDeleted
        existing.updatedAt = member.updatedAt
        
        storage[member.id] = existing
    }
    private func seedIfNeeded() async {
        guard storage.isEmpty else { return }

        let kurosaki = MemberCore(
            id: MemberID(),
            memberName: "Kurosaki",
            isVisible: true,
            isDeleted: false,
            schemaVersion: 1,
            createdAt: Date(),
            updatedAt: Date()
        )

        let mori = MemberCore(
            id: MemberID(),
            memberName: "Mori",
            isVisible: true,
            isDeleted: false,
            schemaVersion: 1,
            createdAt: Date(),
            updatedAt: Date()
        )

        storage[kurosaki.id] = kurosaki
        storage[mori.id] = mori
    }
}
