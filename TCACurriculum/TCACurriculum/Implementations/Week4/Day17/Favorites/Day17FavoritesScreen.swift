//
//  Day17FavoritesScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/09.
//

import SwiftUI
import ComposableArchitecture

struct Day17FavoritesScreen: View {
    @Bindable var store: StoreOf<Day17FavoritesFeature>

    var body: some View {
        List(store.filterItems) { item in
            Text(item.name)
        }
    }
}

#Preview {
    Day17FavoritesScreen(store: Store(initialState: Day17FavoritesFeature.State(items: IdentifiedArray(uniqueElements: Day17Item.mockDay17Item()))) {
        Day17FavoritesFeature()
    })
}
