import Foundation

struct Event: Equatable, Identifiable {
    let id: UUID
    var eventDate: Date
    var eventName: String
    var transName: String
    var memberNames: [String]
    var tagNames: [String]
    var kmPerGas: Double
    var gasPrice: Double
    var payMemberName: String

    init(
        id: UUID = UUID(),
        eventDate: Date,
        eventName: String,
        transName: String,
        memberNames: [String],
        tagNames: [String],
        kmPerGas: Double,
        gasPrice: Double,
        payMemberName: String
    ) {
        self.id = id
        self.eventDate = eventDate
        self.eventName = eventName
        self.transName = transName
        self.memberNames = memberNames
        self.tagNames = tagNames
        self.kmPerGas = kmPerGas
        self.gasPrice = gasPrice
        self.payMemberName = payMemberName
    }
}
