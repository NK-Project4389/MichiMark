import ComposableArchitecture

private enum MemberRepositoryKey: DependencyKey {
    static let liveValue: MemberRepository = InMemoryMemberRepository()
}

extension DependencyValues {
    var memberRepository: MemberRepository {
        get { self[MemberRepositoryKey.self] }
        set { self[MemberRepositoryKey.self] = newValue }
    }
}
