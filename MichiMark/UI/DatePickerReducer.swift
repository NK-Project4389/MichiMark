import ComposableArchitecture
import SwiftUI

@Reducer
struct DatePickerReducer {
    @ObservableState
    struct State: Equatable {
        var date: Date
        var title: String = "日付を選択"
    }

    enum Action: Equatable {
        case dateChanged(Date)
        case doneTapped
        case cancelTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case selected(Date)
            case cancelled
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .dateChanged(date):
                state.date = date
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
    let store: StoreOf<DatePickerReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                DatePicker(
                    "",
                    selection: viewStore.binding(
                        get: \.date,
                        send: DatePickerReducer.Action.dateChanged
                    ),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .navigationTitle(viewStore.title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("キャンセル") { viewStore.send(.cancelTapped) }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完了") { viewStore.send(.doneTapped) }
                    }
                }
                .padding()
            }
        }
    }
}
