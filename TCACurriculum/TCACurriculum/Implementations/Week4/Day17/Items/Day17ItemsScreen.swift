//
//  Day17ItemsScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/09.
//

import SwiftUI
import ComposableArchitecture

struct Day17ItemsScreen: View {
    @Bindable var store: StoreOf<Day17ItemsFeature>

    var body: some View {
        List(store.items) { item in
            HStack {
                Text(item.name)

                Spacer()

                if store.favoriteIDs.contains(item.id) {
                    Button {
                        store.send(.removeFavorite(item))
                    } label: {
                        Image(systemName: "star.fill")
                    }
                } else {
                    Button {
                        store.send(.addFavorite(item))
                    } label: {
                        Image(systemName: "star")
                    }
                }
            }
        }
    }
}

#Preview {
    Day17ItemsScreen(store: Store(initialState: Day17ItemsFeature.State(items: [
        .init(id: "1", name: "item1"),
        .init(id: "2", name: "item2"),
        .init(id: "3", name: "item3")
    ])) {
        Day17ItemsFeature()
    })
}
