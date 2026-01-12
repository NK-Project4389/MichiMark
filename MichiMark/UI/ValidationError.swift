public enum ValidationError: Equatable {
    case empty
    case notNumber
    case outOfRange
    case messages([String])
}
