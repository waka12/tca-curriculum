//
//  Day6TimerFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/25.
//

import ComposableArchitecture

@Reducer
struct Day6TimerFeature {
    @ObservableState
    struct State: Equatable {
        var timerState: TimerState = .pause
        var timerValue: Int = 0
    }

    enum TimerState {
        case pause
        case inProgress
    }

    private enum CancelID {
        case timer
    }

    enum Action: BindableAction {
        case resetButtonTapped
        case pauseButtonTapped
        case playButtonTapped
        case tick
        case binding(BindingAction<State>)
    }

    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .resetButtonTapped:
                state.timerState = .pause
                state.timerValue = 0
                return .cancel(id: CancelID.timer)
            case .pauseButtonTapped:
                state.timerState = .pause
                return .cancel(id: CancelID.timer)
            case .playButtonTapped:
                state.timerState = .inProgress
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.tick)
                    }
                }
                .cancellable(id: CancelID.timer)
            case .tick:
                state.timerValue += 1
                return .none
            case .binding:
                return .none
            }
        }
    }
}
