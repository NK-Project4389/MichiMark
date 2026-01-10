// MichiMarkInfoView.swift
import SwiftUI
import ComposableArchitecture

struct LinkDetailView: View {

    let store: Store<LinkDetailReducer.State, LinkDetailReducer.Action>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { _ in
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 0) {
                        section(title: "場所")
                        section(title: "メンバー")
                        section(title: "走行距離", trailing: "km")
                        section(title: "行動", subtitle: "行動追加")
                        section(title: "メモ")
                        section(title: "給油")
                    }
                }

                saveButton
            }
            .navigationTitle("リンク詳細")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func section(
        title: String,
        subtitle: String? = nil,
        trailing: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                if let trailing {
                    Text(trailing)
                        .foregroundColor(.secondary)
                }
            }

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .overlay(
            Divider(), alignment: .bottom
        )
    }

    private var saveButton: some View {
        Button("保存") {}
            .padding()
            .background(Color(.systemGray4))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding()
    }
}
