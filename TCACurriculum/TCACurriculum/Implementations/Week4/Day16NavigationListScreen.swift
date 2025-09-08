//
//  Day16NavigationListScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/08.
//

import SwiftUI
import ComposableArchitecture

struct Day16NavigationListScreen: View {
    @Bindable var store: StoreOf<Day16NavigationListFeature>

    var body: some View {
        NavigationStack {
            List(store.items) { item in
                Button(item.name) {
                    store.send(.itemRowTapped(item))
                }
            }
            .navigationDestination(item: $store.scope(state: \.destination?.detail, action: \.destination.detail)) { store in
                Day16NavigationDetailScreen(store: store)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    Day16NavigationListScreen(store: Store(initialState: Day16NavigationListFeature.State()) {
        Day16NavigationListFeature()
    })
}
