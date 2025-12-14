import ComposableArchitecture

@CasePathable
enum EventListAction: Equatable {
    case onAppear
    case refresh
    case eventTapped(Event)
    case addTapped
    case settingsTapped
    case eventsResponse([Event])
    case eventDetail(EventDetail.Action)
}
