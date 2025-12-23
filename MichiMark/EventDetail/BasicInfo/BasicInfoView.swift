import SwiftUI
import ComposableArchitecture

struct BasicInfoView: View {

    let store: StoreOf<BasicInfoReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(spacing: 24) {

                    // ===== 基本情報 =====
                    section {
                        BasicInfoRow(
                            icon: "calendar",
                            title: "日付",
                            value: formattedDate(viewStore.eventDate),
                            showsChevron: true
                        )

                        BasicInfoRow(
                            icon: "text.bubble",
                            title: "イベント名",
                            value: displayText(viewStore.eventName)
                        )

                        BasicInfoRow(
                            icon: "car",
                            title: "車両",
                            value: displayText(viewStore.transName)
                        )
                    }

                    // ===== メンバー =====
                    section {
                        rowHeader(icon: "person.2", title: "メンバー")
                        chipGrid(
                            items: viewStore.memberNames,
                            emptyText: "メンバー追加"
                        )
                    }

                    // ===== タグ =====
                    section {
                        rowHeader(icon: "tag", title: "タグ")
                        chipGrid(
                            items: viewStore.tagNames,
                            emptyText: "タグ追加"
                        )
                    }

                    // ===== 燃費・支払 =====
                    section {
                        BasicInfoRow(
                            icon: "fuelpump",
                            title: "燃費",
                            value: viewStore.kmPerGas.map { String(Int($0)) },
                            unit: "km/ℓ"
                        )

                        BasicInfoRow(
                            icon: "yensign.circle",
                            title: "ガソリン単価",
                            value: viewStore.gasPrice.map { String($0) },
                            unit: "円/ℓ"
                        )

                        BasicInfoRow(
                            icon: "creditcard",
                            title: "支払者",
                            value: viewStore.payMemberName ?? "未選択",
                            showsChevron: true
                        )
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                saveButton
            }
        }
    }

    // MARK: - Section
    private func section<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    // MARK: - Header
    private func rowHeader(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)

            Text(title)
                .font(.body)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Chip Grid
    @ViewBuilder
    private func chipGrid(
        items: [String],
        emptyText: String
    ) -> some View {
        if items.isEmpty {
            Text(emptyText)
                .foregroundColor(.secondary)
                .padding(.vertical, 4)
        } else {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 44))],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(items, id: \.self) { item in
                    ChipView(text: item)
                }
            }
        }
    }

    // MARK: - Date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd(E)"
        return formatter.string(from: date)
    }

    // MARK: - Text
    private func displayText(_ text: String) -> String {
        text.isEmpty ? "入力" : text
    }

    // MARK: - Save Button
    private var saveButton: some View {
        HStack {
            Spacer()
            Button {
                // 処理は後工程
            } label: {
                Text("保存")
                    .fontWeight(.bold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 4)
            }
        }
        .padding()
    }
}

private struct ChipView: View {

    let text: String

    var body: some View {
        Text(text.prefix(2))
            .font(.caption)
            .frame(width: 36, height: 36)
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .clipShape(Circle())
    }
}
