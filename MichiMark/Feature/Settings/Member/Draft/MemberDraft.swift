import Foundation

public struct MemberDraft: Equatable {
    var memberName: String
    var mailAddress: String
    var isVisible: Bool

    init(projection: MemberItemProjection) {
        self.memberName = projection.memberName
        self.mailAddress = projection.mailAddress ?? ""
        self.isVisible = projection.isVisible
    }
}
