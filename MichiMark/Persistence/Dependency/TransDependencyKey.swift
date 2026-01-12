import ComposableArchitecture

private enum TransRepositoryKey: DependencyKey {
    static let liveValue: TransRepository = InMemoryTransRepository()
}

extension DependencyValues {
    var transRepository: TransRepository {
        get { self[TransRepositoryKey.self] }
        set { self[TransRepositoryKey.self] = newValue }
    }
}
