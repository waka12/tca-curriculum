//
//  Day19ParentScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/11.
//

import SwiftUI
import ComposableArchitecture

struct Day19ParentScreen: View {
    @Bindable var store: StoreOf<Day19ParentFeature>

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Button("Count") {
                    store.send(.showCountButtonTapped)
                }

                Button("Display") {
                    store.send(.showDisplayButtonTapped)
                }
            }
            .navigationDestination(item: $store.scope(state: \.destination?.count, action: \.destination.count)) { store in
                Day19CounterScreen(store: store)
            }
            .navigationDestination(item: $store.scope(state: \.destination?.display, action: \.destination.display)) { store in
                Day19DisplayScreen(store: store)
            }
        }
    }
}

#Preview {
    Day19ParentScreen(store: Store(initialState: Day19ParentFeature.State(count: Shared(value: 0))) {
        Day19ParentFeature()
    })
}
