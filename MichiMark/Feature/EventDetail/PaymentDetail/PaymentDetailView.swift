import SwiftUI
import ComposableArchitecture

struct PaymentDetailView: View {

    @Bindable var store: StoreOf<PaymentDetailReducer>

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - 金額
                section {
                    HStack(spacing: 8) {
                        TextField(
                            "金額",
                            text: Binding(
                                get: { store.draft.paymentAmount.map(String.init) ?? "" },
                                set: { store.send(.paymentAmountChanged($0)) }
                            )
                        )
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)

                        Text("円")
                            .foregroundColor(.secondary)
                    }
                }

                // MARK: - 支払者
                section {
                    Button {
                        store.send(.payMemberTapped)
                    } label: {
                        BasicInfoRow(
                            icon: "creditcard",
                            title: "支払者",
                            value: store.draft.payMemberName,
                            showsChevron: true
                        )
                    }
                }

                // MARK: - 割り勘メンバー
                section {
                    Button {
                        store.send(.splitMembersTapped)
                    } label: {
                        BasicInfoRow(
                            icon: "person.2",
                            title: "割り勘メンバー",
                            value: store.draft.splitMemberIDs.isEmpty
                                ? nil
                                : "\(store.draft.splitMemberIDs.count)人",
                            showsChevron: true
                        )
                    }

                    if !store.draft.splitMemberNames.isEmpty {
                        Text(
                            store.draft.splitMemberNames
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
                    ZStack(alignment: .topLeading) {
                        TextEditor(
                            text: Binding(
                                get: { store.draft.paymentMemo },
                                set: { store.send(.paymentMemoChanged($0)) }
                            )
                        )
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4))
                        )

                        if store.draft.paymentMemo.isEmpty {
                            Text("メモ")
                                .foregroundColor(.secondary)
                                .padding(.top, 10)
                                .padding(.leading, 6)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("その他情報詳細")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button("反映") {
                store.send(.applyButtonTapped)
            }
        )
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
