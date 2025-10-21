//
//  Day32TowCounterScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/10/21.
//

import SwiftUI
import ComposableArchitecture

struct Day32TowCounterScreen: View {
    @Bindable var store: StoreOf<Day32TowCounterFeature>

    var body: some View {
        let _ = Self._printChanges()
        List {
            Section {
                Text("Total: \(store.totalCount)")
            }
            Section {
                Day32CounterView(
                    name: store.counterA.name,
                    value: store.counterA.value,
                    incrementButtonTapped: {
                        store.send(.counterA(.increment))
                    }, decrementButtonTapped: {
                        store.send(.counterA(.decrement))
                    }
                )
                Day32CounterView(
                    name: store.counterB.name,
                    value: store.counterB.value,
                    incrementButtonTapped: {
                        store.send(.counterB(.increment))
                    }, decrementButtonTapped: {
                        store.send(.counterB(.decrement))
                    }
                )
            }
            Section {
                ForEach(store.historyLogs) { historyLog in
                    Text(historyLog.text)
                }
            }
        }
    }
}

#Preview {
    Day32TowCounterScreen(store: Store(initialState: Day32TowCounterFeature.State()) {
        Day32TowCounterFeature()
    })
}

private struct Day32CounterView: View {
    let name: String
    let value: Int
    let incrementButtonTapped: () -> Void
    let decrementButtonTapped: () -> Void

    var body: some View {
        let _ = Self._printChanges()
        HStack {
            Text("Counter \(name): \(value)")
            Button("+") {
                incrementButtonTapped()
            }
            .buttonStyle(.plain)
            Button("-") {
                decrementButtonTapped()
            }
            .buttonStyle(.plain)
        }
    }
}
