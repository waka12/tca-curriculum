//
//  Day32TowCounterFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day32TowCounterFeature {
    @ObservableState
    struct State {
        var counterA: CounterState = .init(id: UUID(), name: "A")
        var counterB: CounterState = .init(id: UUID(), name: "B")
        var totalCount: Int {
            counterA.value + counterB.value
        }
        var historyLogs: IdentifiedArrayOf<HistoryLog> = []
    }

    enum Action {
        case counterA(CounterAction)
        case counterB(CounterAction)
        case logAdded(HistoryLog)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .counterA(counterAction):
                switch counterAction {
                case .increment:
                    state.counterA.value += 1
                    return .send(.logAdded(HistoryLog(id: UUID(), text: "A increased to \(state.counterA.value)")))
                case .decrement:
                    state.counterA.value -= 1
                    return .send(.logAdded(HistoryLog(id: UUID(), text: "A decreased to \(state.counterA.value)")))
                }

            case let .counterB(counterAction):
                switch counterAction {
                case .increment:
                    state.counterB.value += 1
                    return .send(.logAdded(HistoryLog(id: UUID(), text: "B increased to \(state.counterB.value)")))
                case .decrement:
                    state.counterB.value -= 1
                    return .send(.logAdded(HistoryLog(id: UUID(), text: "B decreased to \(state.counterB.value)")))
                }

            case let .logAdded(logEntry):
                state.historyLogs.append(logEntry)
                if state.historyLogs.count > 5 {
                    state.historyLogs.removeFirst()
                }
                return .none
            }
        }
    }
}

struct CounterState: Identifiable, Equatable {
    var id: UUID
    var name: String
    var value: Int = 0
}

enum CounterAction {
    case increment
    case decrement
}

struct HistoryLog: Identifiable, Equatable {
    var id: UUID
    var text: String
}
