import ComposableArchitecture
import SwiftUI

@Reducer
struct DatePickerReducer {
    @ObservableState
    struct State: Equatable {
        var date: Date
        var title: String = "日付を選択"
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case doneTapped
        case cancelTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case selected(Date)
            case cancelled
        }
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .doneTapped:
                return .send(.delegate(.selected(state.date)))

            case .cancelTapped:
                return .send(.delegate(.cancelled))
            case .delegate:
                return .none
            }
        }
    }
}

struct DatePickerView: View {
    @Bindable var store: StoreOf<DatePickerReducer>

    var body: some View {
        WithPerceptionTracking {
            DatePicker(
                "",
                selection: $store.date,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .navigationTitle(store.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { store.send(.cancelTapped) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { store.send(.doneTapped) }
                }
            }
            .padding()
        }
    }
}
