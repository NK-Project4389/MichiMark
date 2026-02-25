import Foundation

public struct MemberDraft: Equatable, Sendable {
    var memberName: String
    var mailAddress: String
    var isVisible: Bool
    var isHidden: Bool {
        get { !isVisible }
        set { isVisible = !newValue }
    }

    init(projection: MemberItemProjection) {
        self.memberName = projection.memberName
        self.mailAddress = projection.mailAddress ?? ""
        self.isVisible = projection.isVisible
    }
}
