import ComposableArchitecture
import Foundation

@Reducer
struct TransSettingCreateReducer {

    @ObservableState
    struct State {
        var detail: TransSettingDetailReducer.State

        init() {
            let newID = TransID()
            let domain = TransDomain(id: newID, transName: "")
            let projection = TransProjectionAdapter().adapt(domain)
            self.detail = TransSettingDetailReducer.State(projection: projection)
        }
    }

    enum Action {
        case detail(TransSettingDetailReducer.Action)
    }

    @Dependency(\.transRepository) var transRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .detail(.delegate(.saveRequested(transID, draft))):
                let domain = draft.toDomain(id: transID)
                return .run { send in
                    do {
                        try await transRepository.save(domain)
                        await send(.detail(.savingFinished))
                    } catch {
                        await send(
                            .detail(
                                .saveFailed("保存に失敗しました。再度お試しください。")
                            )
                        )
                    }
                }

            default:
                return .none
            }
        }
        Scope(state: \.detail, action: \.detail) {
            TransSettingDetailReducer()
        }
    }
}
