import SwiftUI
import ComposableArchitecture

struct TransSettingDetailView: View {

    let store: StoreOf<TransSettingDetailReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {

                formRow(title: "交通手段名") {
                    TextField("入力", text: viewStore.binding(
                        get: {$0.draft.transName},
                        send: TransSettingDetailReducer.Action.transNameChanged
                    ))
                }

                formRow(title: "燃費", trailing: "km/ℓ") {
                    TextField("入力", text: viewStore.binding(
                        get: {$0.draft.displayKmPerGas},
                        send: TransSettingDetailReducer.Action.kmPerGasChanged
                    ))
                    .keyboardType(.decimalPad)
                }

                formRow(title: "メーター", trailing: "km") {
                    TextField("入力", text: viewStore.binding(
                        get: {$0.draft.displayMeterValue},
                        send: TransSettingDetailReducer.Action.meterValueChanged
                    ))
                    .keyboardType(.numberPad)
                }

                Toggle("非表示", isOn: viewStore.binding(
                    get: { !$0.draft.isVisible },
                    send: { _ in .visibleToggled }
                ))
                .padding()

                Spacer()

                Button("保存") {
                    viewStore.send(.saveTapped)
                }
                .padding()
                .background(Color(.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding()
            }
            .navigationTitle("交通手段詳細")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func formRow<Content: View>(
        title: String,
        trailing: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                if let trailing {
                    Text(trailing)
                        .foregroundColor(.secondary)
                }
            }
            content()
        }
        .padding()
        .overlay(Divider(), alignment: .bottom)
    }
}
