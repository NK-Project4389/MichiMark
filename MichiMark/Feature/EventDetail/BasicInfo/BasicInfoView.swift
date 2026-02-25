import SwiftUI
import ComposableArchitecture

struct BasicInfoView: View {

    @Bindable var store: StoreOf<BasicInfoReducer>

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                section {
                    TextField(
                        "イベント名",
                        text: $store.draft.eventName
                    )
                    .textFieldStyle(.roundedBorder)

                    Button {
                        store.send(.transTapped)
                    } label: {
                        BasicInfoRow(
                            icon: "car",
                            title: "交通手段",
                            value: store.draft.selectedTransName ?? "未設定",
                            showsChevron: true
                        )
                    }

                    
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
                            store.draft.selectedMemberNames.values.joined(separator: ", ")
                        )
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    }

                    
                    Button {
                        store.send(.tagsTapped)
                    } label: {
                        BasicInfoRow(
                            icon: "tag",
                            title: "タグ",
                            value: nil,
                            showsChevron: true
                        )
                    }

                    if !store.draft.selectedTagIDs.isEmpty {
                        Text(
                            store.draft.selectedTagNames.values.joined(separator: ", ")
                        )
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    }

                }

                section {
                    TextField(
                        "km/L",
                        text: $store.draft.kmPerGas
                    )
                    .keyboardType(.decimalPad)

                    TextField(
                        "円/L",
                        text: $store.draft.pricePerGas
                    )
                    .keyboardType(.numberPad)
                    
                    Button {
                        store.send(.payMemberTapped)
                    } label: {
                        BasicInfoRow(
                            icon: "banknote",
                            title: "支払者",
                            value: store.draft.selectedPayMemberName ?? "未設定",
                            showsChevron: true
                        )
                    }

                }
                
            }
            .padding(.horizontal)
        }
        .navigationBarItems(
            trailing: Button("保存") {
                store.send(.saveTapped)
            }
        )
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
