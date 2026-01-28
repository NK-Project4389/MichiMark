import ComposableArchitecture
import Foundation

@Reducer
struct FuelDetailReducer {

    @ObservableState
    struct State: Equatable {
        var pricePerGas: String
        var gasQuantity: String
        var gasPrice: String
    }

    enum Action {
        case pricePerGasChanged(String)
        case gasQuantityChanged(String)
        case gasPriceChanged(String)
        case clearTapped
        case calculateTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .pricePerGasChanged(let value):
                state.pricePerGas = value
                return .none

            case .gasQuantityChanged(let value):
                state.gasQuantity = value
                return .none

            case .gasPriceChanged(let value):
                state.gasPrice = value
                return .none


            case .clearTapped:
                state.pricePerGas = ""
                state.gasQuantity = ""
                state.gasPrice = ""
                return .none
            
            case .calculateTapped:
                let price = Int(state.pricePerGas)
                let quantity = Double(state.gasQuantity)
                let total = Int(state.gasPrice)

                // 単価は必須・再計算対象外
                guard let price else { return .none }

                let emptyCount = [
                    state.gasQuantity.isEmpty,
                    state.gasPrice.isEmpty
                ].filter { $0 }.count

                // 未入力が1つだけのときのみ計算
                guard emptyCount == 1 else { return .none }

                // 合計が空 → 単価 × 給油量
                if state.gasPrice.isEmpty, let quantity {
                    state.gasPrice = String(Int(Double(price) * quantity))
                    return .none
                }

                // 給油量が空 → 合計 ÷ 単価
                if state.gasQuantity.isEmpty, let total, price != 0 {
                    let q = Double(total) / Double(price)
                    state.gasQuantity = String(format: "%.1f", q)
                    return .none
                }

                return .none

            }
        }
    }
}
