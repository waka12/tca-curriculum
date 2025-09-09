//
//  Day17ItemsFeature.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/09.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Day17ItemsFeature {
    @ObservableState
    struct State {
        var items: IdentifiedArrayOf<Day17Item>
        @Shared(.inMemory("favoriteIDs"))
        var favoriteIDs: Set<String> = []
    }

    enum Action {
        case addFavorite(Day17Item)
        case removeFavorite(Day17Item)
    }

    @Dependency(\.uuid) var uuid
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .addFavorite(item):
                state.$favoriteIDs.withLock { $0.insert(item.id) }
                return .none
            case let.removeFavorite(item):
                state.$favoriteIDs.withLock { $0.remove(item.id) }
                return .none
            }
        }
    }
}
