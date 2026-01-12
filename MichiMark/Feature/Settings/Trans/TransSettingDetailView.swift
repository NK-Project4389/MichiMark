import SwiftUI
import ComposableArchitecture

private struct ViewState: Equatable {
    let draft: TransDraft
    let isSaving: Bool

    init(state: TransSettingDetailReducer.State) {
        self.draft = state.draft
        self.isSaving = state.isSaving
    }
}

struct TransSettingDetailView: View {

    let store: StoreOf<TransSettingDetailReducer>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ZStack {
                VStack(spacing: 0) {
                    formRow(title: "交通手段名") {
                        TextField(
                            "入力",
                            text: viewStore.binding(
                                get: { $0.draft.transName },
                                send: TransSettingDetailReducer.Action.transNameChanged
                            )
                        )
                    }
                    
                    formRow(title: "燃費", trailing: "km/ℓ") {
                        TextField("入力", text: viewStore.binding(
                            get: {$0.draft.displayKmPerGas},
                            send: TransSettingDetailReducer.Action.kmPerGasChanged
                        ))
                        .keyboardType(.decimalPad)
                    }
                    
                    formRow(title: "メーター", trailing: "km") {
                        TextField(
                            "入力",
                            text: viewStore.binding(
                                get: { formatComma($0.draft.displayMeterValue) },
                                send: TransSettingDetailReducer.Action.meterValueChanged
                            )
                        )
                        .keyboardType(.numberPad)

                    }

                    Toggle(
                        "非表示",
                        isOn: viewStore.binding(
                            get: { !$0.draft.isVisible },
                            send: { _ in .visibleToggled }
                        )
                    )
                    .padding()

                    Spacer()

                    Button("保存") {
                        viewStore.send(.saveTapped)
                    }
                    .padding()
                    .background(Color(.systemGray4))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding()
                    
                    .navigationTitle("タグ詳細")
                    .navigationBarTitleDisplayMode(.inline)
                }

                if viewStore.isSaving {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()

                    ProgressView("保存中...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                }
            }
            .disabled(viewStore.isSaving)
        }
        .alert(
            store: store.scope(
                state: \.$alert,
                action: TransSettingDetailReducer.Action.alert
            )
        )
        
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
    
    private func formatComma(_ text: String) -> String {
        let raw = text.replacingOccurrences(of: ",", with: "")
        guard let value = Int(raw) else { return text }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? text
    }

}
