//
//  Day17AppScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/09.
//

import SwiftUI
import ComposableArchitecture

struct Day17AppScreen: View {
    @Bindable var store: StoreOf<Day17AppFeature>

    var body: some View {
        TabView {
            Day17ItemsScreen(
                store: store.scope(state: \.items, action: \.items)
            )
            .tabItem { Text("Items") }

            Day17FavoritesScreen(
                store: store.scope(state: \.favorites, action: \.favorites)
            )
            .tabItem { Text("Favorites") }
        }
    }
}

#Preview {
    Day17AppScreen(store: Store(initialState: Day17AppFeature.State()) {
        Day17AppFeature()
    })
}
