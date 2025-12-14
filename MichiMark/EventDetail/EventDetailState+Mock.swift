import Foundation

extension EventDetail.State {

    static func mock() -> Self {
        .init(
            selectedTab: .basic,
            basicInfoState: BasicInfoState(
                eventDate: Date(),
                eventName: "テスト",
                transName: "車",
                memberNames: ["黒崎", "森"],
                tagNames: ["旅行"],
                kmPerGas: 15.0,
                gasPrice: 170,
                payMemberName: "黒崎"
            )
,
            michiInfoState: .init(),
            paymentInfoState: .init(),
            summaryState: .init(),
            routeInfoState: .init()
        )
    }
}
