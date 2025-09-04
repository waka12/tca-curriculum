//
//  Day1CounterFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/20.
//

import ComposableArchitecture

@Reducer
struct Day1CounterFeature {
    @ObservableState
    struct State: Equatable {
        var count: Int = 0
        var doubleCount: Int { count * 2 }
    }

    enum Action {
        case increaseButtonTapped
        case decreaseButtonTapped
        case resetButtonTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .increaseButtonTapped:
                state.count += 1
                return .none
            case .decreaseButtonTapped:
                guard state.count > 0 else { return .none }
                state.count -= 1
                return .none
            case .resetButtonTapped:
                state.count = 0
                return .none
            }
        }
    }
}
