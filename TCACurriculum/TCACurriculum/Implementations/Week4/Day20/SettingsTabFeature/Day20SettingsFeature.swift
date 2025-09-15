//
//  Day20SettingsFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture

@Reducer
struct Day20SettingsFeature {
    @ObservableState
    struct State {
        var notificationToggle: Bool = false
        @Shared(.inMemory("messages"))
        var isSendingMentionMessage: Bool = false
    }

    enum Action {
        case sendingButtonTapped
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .sendingButtonTapped:
                state.$isSendingMentionMessage.withLock {
                    $0 = true
                }
                return .none
            case .binding(\.notificationToggle):
                state.notificationToggle.toggle()
                return .none
            case .binding:
                return .none
            }
        }
    }
}

