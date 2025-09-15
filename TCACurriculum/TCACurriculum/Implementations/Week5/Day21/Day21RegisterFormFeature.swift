//
//  Day21RegisterFormFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/15.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day21RegisterFormFeature {
    @ObservableState
    struct State {
        var email: String = ""
        var password: String = ""
        var confirmPassword: String = ""
        var isAgree: Bool = false

        var emailError: String?
        var passwordError: String?
        var confirmPasswordError: String?

        var isValid: Bool {
            emailError == nil &&
            passwordError == nil &&
            confirmPasswordError == nil &&
            isAgree &&
            !email.isEmpty && !password.isEmpty
        }
    }

    enum Action: BindableAction {
        case agreeButtonTapped
        case submitButtonTapped
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.email):
                guard !state.email.isEmpty else { return .none }
                state.emailError = isEmail(state.email) ? nil : "emailを入力してください"
                return .none
            case .binding(\.password):
                guard !state.password.isEmpty else { return .none }
                state.passwordError = isPassword(state.password) ? nil : "8文字以上で入力してください"
                if !state.confirmPassword.isEmpty {
                    state.confirmPasswordError = isMatchPassword(password: state.password, confirmPassword: state.confirmPassword) ? nil : "パスワードが一致していません"
                }
                return .none
            case .binding(\.confirmPassword):
                guard !state.confirmPassword.isEmpty else { return .none }
                state.confirmPasswordError = isMatchPassword(password: state.password, confirmPassword: state.confirmPassword) ? nil : "パスワードが一致していません"
                return .none
            case .agreeButtonTapped:
                state.isAgree.toggle()
                return .none
            case .submitButtonTapped:
                return .none
            case .binding:
                return .none
            }
        }
    }
}

extension Day21RegisterFormFeature {
    private func isEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func isPassword(_ password: String) -> Bool {
        return password.count >= 8
    }

    private func isMatchPassword(password: String, confirmPassword: String) -> Bool {
        password == confirmPassword
    }
}
