enum DraftValidationError: Error, Equatable {
    case requiredFieldMissing(field: Field)
    case invalidFormat(field: Field)
    case outOfRange(field: Field)
}
