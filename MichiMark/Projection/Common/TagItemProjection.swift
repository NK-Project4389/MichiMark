public struct TagItemProjection: Identifiable, Equatable {
    public let id: TagID
    public let tagName: String
    public let isVisible: Bool
    
    init(domain: TagDomain) {
        self.id = domain.id
        self.tagName = domain.tagName
        self.isVisible = domain.isVisible
    }
}
