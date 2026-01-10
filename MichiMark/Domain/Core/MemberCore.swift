import Foundation

struct MemberCore: Equatable {
    let id: MemberID

    var memberName: String
    var mailAddress: String?

    var isVisible: Bool
    var isDeleted: Bool

    var schemaVersion: Int
    let createdAt: Date
    var updatedAt: Date
}
