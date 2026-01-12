import ComposableArchitecture

private enum TagRepositoryKey: DependencyKey {
    static let liveValue: TagRepository = InMemoryTagRepository()
}

extension DependencyValues {
    var tagRepository: TagRepository {
        get { self[TagRepositoryKey.self] }
        set { self[TagRepositoryKey.self] = newValue }
    }
}
