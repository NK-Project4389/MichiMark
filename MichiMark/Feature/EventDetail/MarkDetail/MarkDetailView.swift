import SwiftUI
import ComposableArchitecture

struct MarkDetailView: View {

    @Bindable var store: StoreOf<MarkDetailReducer>

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - 日付
                section {
                    Button {
                        store.send(.dateTapped)
                    } label: {
                        BasicInfoRow(
                            icon: "calendar",
                            title: "日付",
                            value: store.draft.displayDate,
                            showsChevron: true
                        )
                    }
                }


                // MARK: - 場所
                section {
                    TextField(
                        "地点",
                        text: Binding(
                            get: { store.draft.markLinkName },
                            set: { store.send(.markLinkNameChanged($0)) }
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                }

                // MARK: - メンバー
                section {
                    Button {
                        store.send(.membersTapped)
                    } label: {
                        BasicInfoRow(
                            icon: "person",
                            title: "メンバー",
                            value: nil,
                            showsChevron: true
                        )
                    }

                    if !store.draft.selectedMemberIDs.isEmpty {
                        Text(
                            store.draft.selectedMemberNames
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
                    if store.draft.markLinkType == .mark {
                        TextField(
                            "メーター (km)",
                            text: Binding(
                                get: { store.draft.displayMeterValue },
                                set: { store.send(.meterValueChanged($0)) }
                            )
                        )
                        .keyboardType(.numberPad)
                    }

                    if store.draft.markLinkType == .link {
                        TextField(
                            "走行距離 (km)",
                            text: Binding(
                                get: { store.draft.displayDistanceValue },
                                set: { store.send(.distanceValueChanged($0)) }
                            )
                        )
                        .keyboardType(.numberPad)
                    }
                }

                // MARK: - 行動
                section {
                    Button {
                        store.send(.actionsTapped)
                    } label: {
                        BasicInfoRow(
                            icon: "figure.walk",
                            title: "行動",
                            value: nil,
                            showsChevron: true
                        )
                    }

                    if !store.draft.selectedActionIDs.isEmpty {
                        Text(
                            store.draft.selectedActionNames
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
                        text: Binding(
                            get: { store.draft.memo },
                            set: { store.send(.memoChanged($0)) }
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
                        isOn: Binding(
                            get: { store.draft.isFuel },
                            set: { store.send(.fuelToggled($0)) }
                        )
                    )

                    if store.draft.isFuel {

                        TextField(
                            "単価（円/L）",
                            text: Binding(
                                get: { store.draft.fuelDetail?.pricePerGas ?? "" },
                                set: { store.send(.fuel(.pricePerGasChanged($0))) }
                            )
                        )
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)

                        TextField(
                            "給油量（L）",
                            text: Binding(
                                get: { store.draft.fuelDetail?.gasQuantity ?? "" },
                                set: { store.send(.fuel(.gasQuantityChanged($0))) }
                            )
                        )
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)

                        TextField(
                            "合計金額（円）",
                            text: Binding(
                                get: { store.draft.fuelDetail?.gasPrice ?? "" },
                                set: { store.send(.fuel(.gasPriceChanged($0))) }
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
                                store.send(.fuel(.calculateTapped))
                            }

                            Spacer()

                            Button("給油情報をクリア", role: .destructive) {
                                store.send(.fuel(.clearTapped))
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
                store.send(.applyTapped)
            }
        )
        .navigationDestination(
            item: $store.scope(state: \.destination, action: \.destination)
        ) { destinationStore in
            switch destinationStore.case {
            case let .memberSelection(store):
                SelectionView(store: store)
            case let .actionSelection(store):
                SelectionView(store: store)
            }
        }
        .sheet(
            item: $store.scope(state: \.datePicker, action: \.datePicker)
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
