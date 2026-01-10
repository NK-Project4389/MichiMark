import XCTest
@testable import MichiMark

final class EventAdapterTests: XCTestCase {

    func test_event_adapter_cascades_all_children() {
        let member = TestFactory.memberCore()
        let trans = TestFactory.transCore()

        let core = EventCore(
            id: UUID(),
            eventName: "Trip",
            trans: trans,
            members: [member],
            tags: [],
            kmPerGas: 120,
            pricePerGas: 160,
            payMember: member,
            markLinks: [],
            payments: [],
            isDeleted: false,
            schemaVersion: 1,
            createdAt: Date(),
            updatedAt: Date()
        )

        let domain = EventAdapter.toDomain(core)

        XCTAssertEqual(domain.eventName, "Trip")
        XCTAssertEqual(domain.members.count, 1)
        XCTAssertEqual(domain.trans.transName, "Car")
    }
}
