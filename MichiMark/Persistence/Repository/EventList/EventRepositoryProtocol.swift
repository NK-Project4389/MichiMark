protocol EventRepositoryProtocol: Sendable{
    func fetchAll() async throws -> [EventDomain]
    func fetch(id: EventID) async throws -> EventDomain
    func save(_ event: EventDomain) async throws
    func delete(id: EventID) async throws
}
