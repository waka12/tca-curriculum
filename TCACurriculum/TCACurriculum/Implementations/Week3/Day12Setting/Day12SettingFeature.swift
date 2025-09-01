//
//  Day12SettingFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/02.
//

import ComposableArchitecture
import Foundation

enum Theme: String, CaseIterable {
    case light
    case dark
}

@Reducer
struct Day12SettingFeature {
    @ObservableState
    struct State {
        var theme: Theme = .light
        var notificationEnabled: Bool = false
    }

    enum Action: Equatable, BindableAction {
        case onAppear
        case loadSettings(Theme, Bool)
        case binding(BindingAction<State>)
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let theme = await userDefaultsClient.getTheme()
                    let notificationEnabled = await userDefaultsClient.getNotificationEnabled()
                    await send(.loadSettings(theme, notificationEnabled))
                }
            case .loadSettings(let theme, let enabled):
                state.theme = theme
                state.notificationEnabled = enabled
                return .none
            case .binding(\.theme):
                let theme = state.theme
                return .run { send in
                    await userDefaultsClient.setTheme(theme)
                }
            case .binding(\.notificationEnabled):
                let notificationEnabled = state.notificationEnabled
                return .run { send in
                    await userDefaultsClient.setNotificationEnabled(notificationEnabled)
                }
            case .binding(_):
                return .none
            }
        }
    }
}

struct UserDefaultsClient {
    var setTheme: @Sendable (Theme) async -> Void
    var getTheme: @Sendable () async -> Theme
    var setNotificationEnabled: @Sendable (Bool) async -> Void
    var getNotificationEnabled: @Sendable () async -> Bool
}

extension UserDefaultsClient: DependencyKey {
    static let liveValue = Self(
        setTheme: { theme in
            UserDefaults.standard.set(theme.rawValue, forKey: "theme")
        },
        getTheme: {
            let rawValue = UserDefaults.standard.string(forKey: "theme") ?? Theme.light.rawValue
            return Theme(rawValue: rawValue) ?? .light
        },
        setNotificationEnabled: { enabled in
            UserDefaults.standard.set(enabled, forKey: "notificationEnabled")
        },
        getNotificationEnabled: {
            UserDefaults.standard.bool(forKey: "notificationEnabled")
        }
    )

    static let testValue = Self(
        setTheme: { _ in },
        getTheme: { .light },
        setNotificationEnabled: { _ in },
        getNotificationEnabled: { false }
    )

    static let previewValue = testValue
}

extension DependencyValues {
    var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
