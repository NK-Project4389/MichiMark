public struct MichiInfoListProjection: Equatable {
    public let items: [MarkLinkItemProjection]
}

extension MichiInfoListProjection {
    static var empty: Self {
        Self(items: [])
    }
}

