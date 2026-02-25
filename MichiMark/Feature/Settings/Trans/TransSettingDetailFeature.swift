import ComposableArchitecture
import Foundation

@Reducer
struct TransSettingDetailReducer {

    @ObservableState
    struct State {
        let transID: TransID
        let projection: TransItemProjection
        var draft: TransDraft
        
        var validationError: ValidationError?
        
        var isSaving: Bool = false
        @Presents var alert: AlertState<Action>?
        
        init(projection: TransItemProjection){
            self.transID = projection.id
            self.projection = projection
            self.draft = TransDraft(projection: projection)
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)

        case saveTapped
        case backTapped
        
        case savingFinished
        case saveFailed(String)
        case alert(PresentationAction<Action>)
        case clearAlert
        
        case delegate(Delegate)
        enum Delegate {
            case dismiss
            case saveRequested(TransID, TransDraft)
            case didSave(TransID)
        }
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.draft.transName):
                let text = state.draft.transName
                // ★ Validation 判定
                if text.trimmingCharacters(in: .whitespaces).isEmpty {
                    state.validationError = .empty
                } else {
                    state.validationError = nil
                }
                
                return .send(.clearAlert)
                
            case .binding(\.draft.displayKmPerGas):
                return .send(.clearAlert)
                
            case .binding(\.draft.displayMeterValue):
                state.draft.displayMeterValue = formatComma(state.draft.displayMeterValue)
                return .send(.clearAlert)
                
            case .binding(\.draft.isHidden):
                return .send(.clearAlert)

            case .binding:
                return .none
                
            case .saveTapped:
                state.alert = nil

                let errors = validate(draft: state.draft)
                guard errors.isEmpty else {
                    state.alert = AlertState {
                        TextState("入力エラー")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("OK")
                        }
                    } message: {
                        TextState(errors.joined(separator: "\n"))
                    }
                    return .none
                }

                state.isSaving = true
                return .send(
                    .delegate(.saveRequested(state.transID, state.draft))
                )
                
            case .backTapped:
                return .none
                
            case .savingFinished:
                state.isSaving = false
                return .send(.delegate(.didSave(state.transID)))
                
            case let .saveFailed(message):
                state.isSaving = false
                state.alert = AlertState {
                    TextState("保存エラー")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("OK")
                    }
                } message: {
                    TextState(message)
                }
                return .none
                
            case .clearAlert:
                state.alert = nil
                return .none
                
            case .alert, .delegate:
                return .none
            }
        }
    }
    
    private func validate(draft: TransDraft) -> [String] {
        var errors: [String] = []

        // kmPerGas：小数第1位までの正数
        if let text = draft.displayKmPerGas.nonEmpty {
            let regex = #"^\d+(\.\d)?$"#
            if text.range(of: regex, options: .regularExpression) == nil {
                errors.append("燃費は小数第1位までの数値で入力してください")
            }
        } else {
            errors.append("燃費を入力してください")
        }

        // meterValue：正の整数
        if let text = draft.displayMeterValue.nonEmpty {
            if Int(text.replacingOccurrences(of: ",", with: "")) == nil {
                errors.append("メーターは正の整数で入力してください")
            }
        } else {
            errors.append("メーターを入力してください")
        }

        return errors
    }

    private func formatComma(_ text: String) -> String {
        let raw = text.replacingOccurrences(of: ",", with: "")
        guard let value = Int(raw) else { return text }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? text
    }

}

private extension String {
    var nonEmpty: String? {
        trimmingCharacters(in: .whitespaces).isEmpty ? nil : self
    }
}
