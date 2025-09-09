//
//  Day17FavoritesFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/09.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day17FavoritesFeature {
    @ObservableState
    struct State {
        var items: IdentifiedArrayOf<Day17Item>
        var filterItems: IdentifiedArrayOf<Day17Item> {
            items.filter { favoriteIDs.contains($0.id) }
        }
        @Shared(.inMemory("favoriteIDs"))
        var favoriteIDs: Set<String> = []
    }

    enum Action { }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action { }
        }
    }
}
