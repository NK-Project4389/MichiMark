import Foundation

enum BasicInfoAction: Equatable {

    case eventDateChanged(Date)
    case eventNameChanged(String)
    case transNameChanged(String)

    case addMemberTapped
    case removeMember(String)

    case addTagTapped
    case removeTag(String)

    case kmPerGasChanged(String)
    case gasPriceChanged(String)

    case payMemberTapped
    case appeared
}
