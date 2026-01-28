public struct MichiInfoListProjection: Equatable {
    public let items: [MarkLinkItemProjection]
}

extension MichiInfoListProjection {
    static var empty: Self {
        Self(items: [])
    }
}
extension MichiInfoListProjection {

    static var dummy: Self {
        .init(
            items: [
                .dummy(title: "移動", date: "2026/01/01", markLink: .link, seq: 10),
                .dummy(title: "自宅", date: "2026/01/01", markLink: .mark, seq: 20),
                
                .dummy(title: "ガソリンスタンド", date: "2026/01/02", markLink: .mark, seq: 30),
                .dummy(title: "移動", date: "2026/01/02", markLink: .link, seq: 40),
                .dummy(title: "目的地", date: "2026/01/02", markLink: .mark, seq: 50)
            ]
        )
    }
}

