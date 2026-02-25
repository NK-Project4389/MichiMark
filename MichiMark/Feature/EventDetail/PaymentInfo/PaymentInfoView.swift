import SwiftUI
import ComposableArchitecture

struct PaymentInfoView: View {

    @Bindable var store: StoreOf<PaymentInfoReducer>
//    @Bindable var store: StoreOf<PaymentInfoReducer>

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(spacing: 12) {

                    ForEach(store.projection.items) { payment in
                        Button {
                            store.send(.paymentTapped(payment.id))
                        } label: {
                            paymentRow(payment)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .safeAreaInset(edge: .bottom) {
                addButton {
                    store.send(.plusButtonTapped)
                }
            }
        }
    }

    // MARK: - Row
    private func paymentRow(_ payment: PaymentItemProjection) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(payment.displayAmount)
                    .font(.headline)

                Text(payment.payer.memberName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Add Button
    private func addButton(action: @escaping () -> Void) -> some View {
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
