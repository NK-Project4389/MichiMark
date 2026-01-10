import SwiftUI
import ComposableArchitecture

struct BasicInfoView: View {

    let store: StoreOf<BasicInfoReducer>

    var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ScrollView {
                    VStack(spacing: 24) {

                        section {
                            TextField(
                                "イベント名",
                                text: viewStore.binding(
                                    get: \.draft.eventName,
                                    send: BasicInfoReducer.Action.eventNameChanged
                                )
                            )
                            .textFieldStyle(.roundedBorder)

                            BasicInfoRow(
                                icon: "car",
                                title: "交通手段",
                                value: viewStore.projection.trans?.transName ?? "未設定",
                                showsChevron: true
                            )
                        }

                        section {
                            TextField(
                                "km/L",
                                text: viewStore.binding(
                                    get: \.draft.kmPerGas,
                                    send: BasicInfoReducer.Action.kmPerGasChanged
                                )
                            )
                            .keyboardType(.decimalPad)

                            TextField(
                                "円/L",
                                text: viewStore.binding(
                                    get: \.draft.pricePerGas,
                                    send: BasicInfoReducer.Action.pricePerGasChanged
                                )
                            )
                            .keyboardType(.numberPad)
                        }
                    }
                    .padding(.horizontal)
                }
                .navigationBarItems(
                    trailing: Button("保存") {
                        viewStore.send(.saveTapped)
                    }
                )
            }
        }

    // MARK: - Section
    private func section<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Row
    private func row(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .foregroundColor(.primary)
        }
    }
}
