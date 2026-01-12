import ComposableArchitecture

private enum ActionRepositoryKey: DependencyKey {
    static let liveValue: ActionRepository = InMemoryActionRepository()
}

extension DependencyValues {
    var actionRepository: ActionRepository {
        get { self[ActionRepositoryKey.self] }
        set { self[ActionRepositoryKey.self] = newValue }
    }
}
