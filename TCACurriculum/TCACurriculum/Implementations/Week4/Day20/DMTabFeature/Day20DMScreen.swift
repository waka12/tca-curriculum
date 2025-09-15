//
//  Day20DMScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import SwiftUI
import ComposableArchitecture

struct Day20DMScreen: View {
    @Bindable var store: StoreOf<Day20DMFeature>
    var body: some View {
        NavigationStack {
            List(store.partners) { partner in
                Text(partner.name)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("送信") {
                        store.send(.sendingButtonTapped)
                    }
                }
            }
        }
    }
}

#Preview {
    Day20DMScreen(store: Store(initialState: Day20DMFeature.State()) {
        Day20DMFeature()
    })
}
