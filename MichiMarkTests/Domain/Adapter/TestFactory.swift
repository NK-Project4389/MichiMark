import XCTest
import Foundation
@testable import MichiMark

enum TestFactory {

    static func memberCore(
        id: MemberID = UUID(),
        name: String = "Alice"
    ) -> MemberCore {
        MemberCore(
            id: id,
            memberName: name,
            mailAddress: nil,
            isVisible: true,
            isDeleted: false,
            schemaVersion: 1,
            createdAt: Date(timeIntervalSince1970: 0),
            updatedAt: Date(timeIntervalSince1970: 0)
        )
    }

    static func transCore(
        id: TransID = UUID()
    ) -> TransCore {
        TransCore(
            id: id,
            transName: "Car",
            kmPerGas: 120,
            meterValue: 1000,
            isVisible: true,
            isDeleted: false,
            schemaVersion: 1,
            createdAt: Date(timeIntervalSince1970: 0),
            updatedAt: Date(timeIntervalSince1970: 0)
        )
    }
}
