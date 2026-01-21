import ComposableArchitecture

private enum EventRepositoryKey: DependencyKey {
    static let liveValue: EventRepositoryProtocol = InMemoryEventRepository()
}

extension DependencyValues {
    var eventRepositoryProtocol: EventRepositoryProtocol {
        get { self[EventRepositoryKey.self] }
        set { self[EventRepositoryKey.self] = newValue }
    }
}
