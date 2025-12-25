import ComposableArchitecture

@Reducer
struct SettingsReducer {

    @ObservableState
    struct State: Equatable {
        // メニューのため State は持たない
    }

    enum Action {
        case transSettingSelected
        case memberSettingSelected
        case tagSettingSelected
        case actionSettingSelected
        case backTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}
