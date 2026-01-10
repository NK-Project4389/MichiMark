import XCTest
@testable import MichiMark

final class MarkLinkAdapterTests: XCTestCase {

    func test_markType_setsMeterValue_only() {
        let core = MarkLinkCore(
            id: UUID(),
            markLinkSeq: 1,
            markLinkType: .mark,
            markLinkDate: Date(),
            markLinkName: "Start",
            meterValue: 1000,
            distanceValue: 500, // ← 不正
            actions: [],
            memo: nil,
            isFuel: false,
            pricePerGas: 150,
            gasQuantity: 300,
            gasPrice: 4500,
            isDeleted: false,
            schemaVersion: 1,
            createdAt: Date(),
            updatedAt: Date()
        )

        let domain = MarkLinkAdapter.toDomain(core)

        XCTAssertEqual(domain.meterValue, 1000)
        XCTAssertNil(domain.distanceValue)

        XCTAssertNil(domain.pricePerGas)
        XCTAssertNil(domain.gasQuantity)
        XCTAssertNil(domain.gasPrice)
    }

    func test_linkType_setsDistanceValue_only() {
        let core = MarkLinkCore(
            id: UUID(),
            markLinkSeq: 1,
            markLinkType: .link,
            markLinkDate: Date(),
            markLinkName: "Move",
            meterValue: 1000,   // ← 不正
            distanceValue: 500,
            actions: [],
            memo: nil,
            isFuel: true,
            pricePerGas: 160,
            gasQuantity: 300,
            gasPrice: 4800,
            isDeleted: false,
            schemaVersion: 1,
            createdAt: Date(),
            updatedAt: Date()
        )

        let domain = MarkLinkAdapter.toDomain(core)

        XCTAssertNil(domain.meterValue)
        XCTAssertEqual(domain.distanceValue, 500)

        XCTAssertEqual(domain.gasQuantity, 300)
    }

    func test_isFuel_false_forcesGasValues_nil() {
        var domain = MarkLinkAdapter.toDomain(
            MarkLinkCore(
                id: UUID(),
                markLinkSeq: 1,
                markLinkType: .mark,
                markLinkDate: Date(),
                markLinkName: "Test",
                meterValue: 100,
                distanceValue: nil,
                actions: [],
                memo: nil,
                isFuel: false,
                pricePerGas: 150,
                gasQuantity: 200,
                gasPrice: 3000,
                isDeleted: false,
                schemaVersion: 1,
                createdAt: Date(),
                updatedAt: Date()
            )
        )

        let core = MarkLinkAdapter.toCore(domain, schemaVersion: 1)

        XCTAssertNil(core.pricePerGas)
        XCTAssertNil(core.gasQuantity)
        XCTAssertNil(core.gasPrice)
    }
}
