import SwiftUI
import ComposableArchitecture

struct BasicInfoView: View {

    let store: Store<BasicInfoState, BasicInfoAction>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(spacing: 20) {

                    DatePicker(
                        "",
                        selection: viewStore.binding(
                            get: \.eventDate,
                            send: BasicInfoAction.eventDateChanged
                        ),
                        displayedComponents: .date
                    )

                    TextField(
                        "イベント名",
                        text: viewStore.binding(
                            get: \.eventName,
                            send: BasicInfoAction.eventNameChanged
                        )
                    )

                    TextField(
                        "車両 / 交通手段",
                        text: viewStore.binding(
                            get: \.transName,
                            send: BasicInfoAction.transNameChanged
                        )
                    )
                }
                .padding()
            }
            .onAppear { viewStore.send(.appeared) }
        }
    }
}
