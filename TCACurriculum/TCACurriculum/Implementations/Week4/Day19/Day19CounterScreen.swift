//
//  Day19CounterScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/11.
//

import SwiftUI
import ComposableArchitecture

struct Day19CounterScreen: View {
    @Bindable var store: StoreOf<Day19CounterFeature>

    var body: some View {
        VStack(spacing: 16) {
            Text("\(store.count)")
            Button("+") {
                store.send(.increaseButtonTapped)
            }
        }

    }
}

#Preview {
    Day19CounterScreen(store: Store(initialState: Day19CounterFeature.State(count: 0)) {
        Day19CounterFeature()
    })
}
