//
//  Day26SharedTabFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture

@Reducer
struct Day26SharedTabFeature {
    @ObservableState
    struct State {
        var home = Day26SharedHomeFeature.State()
        var settings = Day26SharedSettingsFeature.State()
    }

    enum Tab {
        case home, settings
    }

    enum Action {
        case home(Day26SharedHomeFeature.Action)
        case settings(Day26SharedSettingsFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) {
            Day26SharedHomeFeature()
        }
        Scope(state: \.settings, action: \.settings) {
            Day26SharedSettingsFeature()
        }
        Reduce { state, action in
            switch action {
            case .home, .settings:
                return .none
            }
        }
    }
}

