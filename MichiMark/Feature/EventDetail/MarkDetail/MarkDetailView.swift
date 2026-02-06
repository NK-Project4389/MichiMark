import SwiftUI
import ComposableArchitecture

private struct ViewState: Equatable {
    let draft: MarkDetailDraft

    init(state: MarkDetailReducer.State) {
        self.draft = state.draft
    }
}


struct MarkDetailView: View {

    let store: StoreOf<MarkDetailReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - 日付
                    section {
                        Button {
                            viewStore.send(.dateTapped)
                        } label: {
                            BasicInfoRow(
                                icon: "calendar",
                                title: "日付",
                                value: viewStore.draft.displayDate,
                                showsChevron: true
                            )
                        }
                    }


                    // MARK: - 場所
                    section {
                        TextField(
                            "地点",
                            text: viewStore.binding(
                                get: \.draft.markLinkName,
                                send: MarkDetailReducer.Action.markLinkNameChanged
                            )
                        )
                        .textFieldStyle(.roundedBorder)
                    }

                    // MARK: - メンバー
                    section {
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
                                viewStore.draft.selectedMemberNames
                                    .values
                                    .joined(separator: ", ")
                            )
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                        }
                    }

                    // MARK: - メーター / 距離
                    section {
                        if viewStore.draft.markLinkType == .mark {
                            TextField(
                                "メーター (km)",
                                text: viewStore.binding(
                                    get: \.draft.displayMeterValue,
                                    send: MarkDetailReducer.Action.meterValueChanged
                                )
                            )
                            .keyboardType(.numberPad)
                        }

                        if viewStore.draft.markLinkType == .link {
                            TextField(
                                "走行距離 (km)",
                                text: viewStore.binding(
                                    get: \.draft.displayDistanceValue,
                                    send: MarkDetailReducer.Action.distanceValueChanged
                                )
                            )
                            .keyboardType(.numberPad)
                        }
                    }

                    // MARK: - 行動
                    section {
                        Button {
                            viewStore.send(.actionsTapped)
                        } label: {
                            BasicInfoRow(
                                icon: "figure.walk",
                                title: "行動",
                                value: nil,
                                showsChevron: true
                            )
                        }

                        if !viewStore.draft.selectedActionIDs.isEmpty {
                            Text(
                                viewStore.draft.selectedActionNames
                                    .values
                                    .joined(separator: ", ")
                            )
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                        }
                    }

                    // MARK: - メモ
                    section {
                        TextField(
                            "メモ",
                            text: viewStore.binding(
                                get: \.draft.memo,
                                send: MarkDetailReducer.Action.memoChanged
                            ),
                            axis: .vertical
                        )
                        .textFieldStyle(.roundedBorder)
                    }

                    // MARK: - 給油
                    // MARK: - 給油（Inline）
                    // MARK: - 給油（Inline）
                    section {
                        Toggle(
                            "給油",
                            isOn: viewStore.binding(
                                get: \.draft.isFuel,
                                send: MarkDetailReducer.Action.fuelToggled
                            )
                        )

                        if viewStore.draft.isFuel {

                            TextField(
                                "単価（円/L）",
                                text: viewStore.binding(
                                    get: { $0.draft.fuelDetail?.pricePerGas ?? "" },
                                    send: { .fuel(.pricePerGasChanged($0)) }
                                )
                            )
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                            TextField(
                                "給油量（L）",
                                text: viewStore.binding(
                                    get: { $0.draft.fuelDetail?.gasQuantity ?? "" },
                                    send: { .fuel(.gasQuantityChanged($0)) }
                                )
                            )
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)

                            TextField(
                                "合計金額（円）",
                                text: viewStore.binding(
                                    get: { $0.draft.fuelDetail?.gasPrice ?? "" },
                                    send: { .fuel(.gasPriceChanged($0)) }
                                )
                            )
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                            // 注意書き
                            Text("※ 単価は計算対象外です")
                                .font(.footnote)
                                .foregroundColor(.secondary)

                            HStack {
                                Button("計算") {
                                    viewStore.send(.fuel(.calculateTapped))
                                }

                                Spacer()

                                Button("給油情報をクリア", role: .destructive) {
                                    viewStore.send(.fuel(.clearTapped))
                                }
                            }
                            .font(.footnote)
                        }
                    }

                }
                .padding(.horizontal)
            }
            .navigationTitle("マーク詳細")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("反映") {
                    viewStore.send(.applyTapped)
                }
            )
        }
        .sheet(
            store: store.scope(state: \.$datePicker, action: \.datePicker)
        ) { store in
            DatePickerView(store: store)
        }

    }

    // MARK: - Section
    private func section<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
