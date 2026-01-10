import SwiftUI
import ComposableArchitecture

struct MichiInfoView: View {

    let store: StoreOf<MichiInfoReducer>

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(store.projection.items) { item in
                    if item.displayDistance == nil {
                        MichiMarkCardView(
                            title: item.title,
                            showsLinkBelow: false
                        )
                        .onTapGesture {
                            store.send(.markTapped(item.id))
                        }
                    } else {
                        MichiLinkView()
                            .onTapGesture {
                                store.send(.linkTapped(item.id))
                            }
                    }
                }
            }
            .padding(.top)
        }
        .safeAreaInset(edge: .bottom) {
            addButton {
                store.send(.addMarkTapped)
            }
        }
        .onAppear {
            store.send(.appeared)
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
