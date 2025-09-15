//
//  Day17AppFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/09.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day17AppFeature {
    @ObservableState
    struct State {
        var selectedTab = Tab.items
        var items = Day17ItemsFeature.State(items: IdentifiedArray(uniqueElements: Day17Item.mockDay17Item()))
        var favorites = Day17FavoritesFeature.State(items: IdentifiedArray(uniqueElements: Day17Item.mockDay17Item()))

        @Shared(.inMemory("favoriteIDs"))
        var favoriteIDs: Set<String> = []
    }

    enum Tab {
        case items, favorites
    }

    enum Action: BindableAction {
        case items(Day17ItemsFeature.Action)
        case favorites(Day17FavoritesFeature.Action)
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.items, action: \.items) {
            Day17ItemsFeature()
        }

        Scope(state: \.favorites, action: \.favorites) {
            Day17FavoritesFeature()
        }

        BindingReducer()
        Reduce { state, action in
            switch action {
            case .items, .favorites:
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}

struct Day17Item: Identifiable {
    var id: String
    var name: String

    static func mockDay17Item() -> [Self] {
        [
            .init(id: "1", name: "item1"),
            .init(id: "2", name: "item2"),
            .init(id: "3", name: "item3")
        ]
    }
}
