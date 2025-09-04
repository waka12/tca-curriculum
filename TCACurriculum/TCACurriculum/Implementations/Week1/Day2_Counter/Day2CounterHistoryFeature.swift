//
//  Day2CounterHistory.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/20.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day2CounterHistoryFeature {
    @ObservableState
    struct State: Equatable {
        var count: Int = 0
        var doubleCount: Int { count * 2 }

        var histories: [HistoryRow] = []
    }

    enum Action {
        case increaseButtonTapped
        case decreaseButtonTapped
        case resetButtonTapped
        case clearHistoryButtonTapped
    }

    @Dependency(\.uuid) var uuid

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .increaseButtonTapped:
                state.count += 1
                addHistory(&state, .increase)
                return .none
            case .decreaseButtonTapped:
                state.count -= 1
                addHistory(&state, .decrease)
                return .none
            case .resetButtonTapped:
                state.count = 0
                addHistory(&state, .reset)
                return .none
            case .clearHistoryButtonTapped:
                state.histories = []
                return .none
            }
        }
    }

    // Reducer内のプライベート関数
     private func addHistory(_ state: inout State, _ history: History) {
         if state.histories.count >= 5 {
             state.histories.removeLast()
         }
         state.histories.insert(
            HistoryRow(id: uuid(), history: history, currentCount: state.count),
             at: 0
         )
     }
}

extension Day2CounterHistoryFeature {
    enum History: String {
        case increase = "+1"
        case decrease = "-1"
        case reset = "リセット"
    }

    struct HistoryRow: Identifiable, Hashable, Equatable {
        var id: UUID
        var history: History
        var currentCount: Int
    }
}
