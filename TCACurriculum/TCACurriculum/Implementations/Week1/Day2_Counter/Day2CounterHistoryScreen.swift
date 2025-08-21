//
//  Day1CounterScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/20.
//

import SwiftUI
import ComposableArchitecture

struct Day2CounterHistoryScreen: View {
    @Bindable var store: StoreOf<Day2CounterHistoryFeature>

    var body: some View {
        VStack(spacing: 16) {
            Text("\(store.count)")
            Text("\(store.doubleCount)")
            HStack(spacing: 24) {
                Button {
                    store.send(.decreaseButtonTapped)
                } label: {
                    Image(systemName: "minus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 15)
                }
                Button {
                    store.send(.increaseButtonTapped)
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 15)
                }
            }
            Button {
                store.send(.resetButtonTapped)
            } label: {
                Image(systemName: "return")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 30)
            }

            List(store.histories) { history in
                VStack {
                    Text("操作履歴: \(history.history.rawValue)")
                    Text("合計数: \(history.currentCount)")
                }
            }
            Button("クリア") {
                store.send(.clearHistoryButtonTapped)
            }
        }
    }
}

#Preview {
    Day2CounterHistoryScreen(
        store: Store(initialState: Day2CounterHistoryFeature.State()) {
            Day2CounterHistoryFeature()
        }
    )
}
