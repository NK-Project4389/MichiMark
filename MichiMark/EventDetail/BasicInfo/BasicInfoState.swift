import Foundation

struct BasicInfoState: Equatable {

    var eventDate: Date
    var eventName: String
    var transName: String

    var memberNames: [String]
    var tagNames: [String]

    var kmPerGas: Double?
    var gasPrice: Int?

    var payMemberName: String?

    static let initial = BasicInfoState(
        eventDate: Date(),
        eventName: "",
        transName: "",
        memberNames: [],
        tagNames: [],
        kmPerGas: nil,
        gasPrice: nil,
        payMemberName: nil
    )
}
