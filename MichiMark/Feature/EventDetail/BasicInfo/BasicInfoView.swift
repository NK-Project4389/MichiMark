import SwiftUI
import ComposableArchitecture

private struct ViewState: Equatable {
    let draft: BasicInfoDraft

    init(state: BasicInfoReducer.State) {
        self.draft = state.draft
    }
}

struct BasicInfoView: View {

    let store: StoreOf<BasicInfoReducer>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
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

                            Button {
                                viewStore.send(.transTapped)
                            } label: {
                                BasicInfoRow(
                                    icon: "car",
                                    title: "交通手段",
                                    value: viewStore.draft.selectedTransName ?? "未設定",
                                    showsChevron: true
                                )
                            }

                            
                            Button {
                                viewStore.send(.membersTapped)
                            } label: {
                                BasicInfoRow(
                                    icon: "person",
                                    title: "メンバー",
                                    value: nil,
                                    showsChevron: true
                                )
                            }

                            if !viewStore.draft.selectedMemberIDs.isEmpty {
                                Text(
                                    viewStore.draft.selectedMemberNames.values.joined(separator: ", ")
                                )
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                            }

                            
                            Button {
                                viewStore.send(.tagsTapped)
                            } label: {
                                BasicInfoRow(
                                    icon: "tag",
                                    title: "タグ",
                                    value: nil,
                                    showsChevron: true
                                )
                            }

                            if !viewStore.draft.selectedTagIDs.isEmpty {
                                Text(
                                    viewStore.draft.selectedTagNames.values.joined(separator: ", ")
                                )
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                            }

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
                            
                            Button {
                                viewStore.send(.payMemberTapped)
                            } label: {
                                BasicInfoRow(
                                    icon: "banknote",
                                    title: "支払者",
                                    value: viewStore.draft.selectedPayMemberName ?? "未設定",
                                    showsChevron: true
                                )
                            }

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
