//
//  Day15LoginFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/06.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Day15LoginFeature {
    @ObservableState
    struct State: Equatable {
        var mailTextField = ""
        var isEmailError: Bool = false
        var passTextField = ""
        var isPassError: Bool = false
        var errorText: String?
        var isLoading: Bool = false
        var authToken: AuthToken?
        var timerValue: Int = 0
    }

    enum Action: BindableAction {
        case onAppear
        case autoLogin(String)
        case loginButtonTapped
        case loginResults(TaskResult<AuthToken>)
        case logout
        case binding(BindingAction<State>)
    }

    private enum CancelID {
        case timer
    }

    @Dependency(\.loginClient) var loginClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.day15UserDefaultsClient) var userDefaultsClient

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let accessToken = await userDefaultsClient.getAuthToken()
                    if !accessToken.isEmpty {
                        await send(.autoLogin(accessToken))
                    }
                }
            case .autoLogin(let accessToken):
                state.authToken = AuthToken(accessToken: accessToken, expiresAt: 10)
                return .run { [expiresAt = state.authToken?.expiresAt] send in
                    try await clock.sleep(for: .seconds(expiresAt ?? 0))
                    await send(.logout)
                }
            case .loginButtonTapped:
                guard !state.mailTextField.isEmpty, !state.passTextField.isEmpty, !state.isEmailError, !state.isPassError else {
                    state.errorText = "正しい情報を入力してください"
                    return .none
                }
                state.isLoading = true
                state.errorText = nil
                return .run { [mail = state.mailTextField, password = state.passTextField] send in
                    await send(.loginResults(
                        TaskResult {
                            try await loginClient.login(mail, password)
                        }
                    ))
                }
            case .loginResults(.success(let authToken)):
                state.authToken = authToken
                state.isLoading = false
                state.mailTextField = ""
                state.passTextField = ""
                return .merge(
                    .run { [authTokenKey = state.authToken?.accessToken] send in
                        await userDefaultsClient.setAuthToken(authTokenKey ?? "")
                    },
                    .run { [expiresAt = state.authToken?.expiresAt] send in
                        try await clock.sleep(for: .seconds(expiresAt ?? 0))
                        await send(.logout)
                    }
                    .cancellable(id: CancelID.timer)
                )
            case .loginResults(.failure(_)):
                state.isLoading = false
                state.errorText = "ログインに失敗しました"
                return .none
            case .logout:
                state.authToken = nil
                return .merge(
                    .cancel(id: CancelID.timer),
                    .run { send in
                        await userDefaultsClient.setAuthToken("")
                    }
                )
            case .binding(\.passTextField):
                guard !state.passTextField.isEmpty else { return .none }
                state.isPassError = !isPassword(state.passTextField)
                return .none
            case .binding(\.mailTextField):
                guard !state.mailTextField.isEmpty else { return .none }
                state.isEmailError = !isEmail(state.mailTextField)
                return .none
            case .binding(_):
                return .none
            }
        }
    }

    private func isEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func isPassword(_ password: String) -> Bool {
        return password.count >= 8
    }
}

struct AuthToken: Equatable, Codable {
    let accessToken: String
    let expiresAt: Int
}

struct LoginClient {
    var login: @Sendable (String, String) async throws -> AuthToken
}

extension LoginClient: DependencyKey {
    static let liveValue = Self(login: { email, password in
        try await Task.sleep(for: .seconds(1))

        if Bool.random() {
            throw LoginError.networkError
        }

        return AuthToken(accessToken: email + password, expiresAt: 10)
    })
}

enum LoginError: Error {
    case networkError
}

struct Day15UserDefaultsClient {
    var setAuthToken: @Sendable (String) async -> Void
    var getAuthToken: @Sendable () async -> String
}

extension Day15UserDefaultsClient: DependencyKey {
    static let liveValue = Self(
        setAuthToken: { token in
            UserDefaults.standard.setValue(token, forKey: "authToken")
        }, getAuthToken: {
            let rawValue = UserDefaults.standard.string(forKey: "authToken")
            return rawValue ?? ""
        }
        )
}

extension DependencyValues {
    var loginClient: LoginClient {
        get { self[LoginClient.self] }
        set { self[LoginClient.self] = newValue }
    }
    var day15UserDefaultsClient: Day15UserDefaultsClient {
        get { self[Day15UserDefaultsClient.self] }
        set { self[Day15UserDefaultsClient.self] = newValue }
    }
}
