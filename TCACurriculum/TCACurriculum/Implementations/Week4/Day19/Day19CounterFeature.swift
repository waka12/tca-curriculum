//
//  Day19CounterFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/11.
//

import ComposableArchitecture

@Reducer
struct Day19CounterFeature {
    @ObservableState
    struct State {
        var count: Int
    }

    enum Action {
        case increaseButtonTapped
        case delegate(Delegate)
        @CasePathable
        enum Delegate {
            case addCount(Int)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .increaseButtonTapped:
                state.count += 1
                return .run { [count = state.count ]send in
                    await send(.delegate(.addCount(count)))
                }
            case .delegate:
                return .none
            }
        }
    }
}
