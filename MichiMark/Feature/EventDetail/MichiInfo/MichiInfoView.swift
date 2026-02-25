import SwiftUI
import ComposableArchitecture

struct MichiInfoView: View {

    @Bindable var store: StoreOf<MichiInfoReducer>

    var body: some View {
        let items = store.displayItems
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in

                    MichiTimelineRowView(
                        item: item,
                        isFirst: index == 0,
                        isLast: index == items.count - 1,
                        onMarkTap: {
                            store.send(.markTapped(item.id))
                        },
                        onLinkTap: {
                            store.send(.linkTapped(item.id))
                        }
                    )
                }
            }
            .padding(.top)
        }
        .safeAreaInset(edge: .bottom) {
            addButton {
                store.send(.addButtonTapped)
            }
        }
    }
}



private extension MichiInfoView {
    var header: some View {
        HStack {
            Text("ミチ情報")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    func addButton(action: @escaping () -> Void) -> some View {
        HStack {
            Spacer()
            Button(action: action) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
        .padding()
    }
}

import SwiftUI

struct TimelineColumnView: View {

    let isFirst: Bool
    let isLast: Bool
    let showsPlus: Bool

    var body: some View {
        VStack(spacing: 0) {

            // 上の線
            if !isFirst {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }

            // ノード（●）
            Circle()
                .fill(Color.black)
                .frame(width: 10, height: 10)

            // ＋（挿入用：今回は表示だけ）
            if showsPlus {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .padding(.vertical, 6)
            }

            // 下の線
            if !isLast {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 24)
        .allowsHitTesting(false)
    }
    
}
