import XCTest
@testable import MichiMark

final class PaymentAdapterTests: XCTestCase {

    func test_paymentMember_isRequired() {
        let core = PaymentCore(
            id: UUID(),
            paymentSeq: 1,
            paymentAmount: 1000,
            paymentMember: nil, // ← 不正
            splitMembers: [],
            paymentMemo: nil,
            isDeleted: false,
            schemaVersion: 1,
            createdAt: Date(),
            updatedAt: Date()
        )

        // fatalError が出ることを仕様として確認
        XCTAssertThrowsError(
            try {
                _ = PaymentAdapter.toDomain(core)
            }()
        )
    }
}
