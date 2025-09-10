//
//  Day19DisplayScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/11.
//

import SwiftUI
import ComposableArchitecture

struct Day19DisplayScreen: View {
    @Bindable var store: StoreOf<Day19DisplayFeature>

    var body: some View {
        VStack(spacing: 16) {
            Text("\(store.count)")
        }

    }
}

#Preview {
    Day19DisplayScreen(store: Store(initialState: Day19DisplayFeature.State(count: Shared(value: 1))) {
        Day19DisplayFeature()
    })
}
