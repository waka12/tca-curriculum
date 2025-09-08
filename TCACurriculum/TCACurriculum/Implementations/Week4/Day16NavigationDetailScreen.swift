//
//  Day16NavigationDetailScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/08.
//

import SwiftUI
import ComposableArchitecture

struct Day16NavigationDetailScreen: View {
    @Bindable var store: StoreOf<Day16NavigationDetailFeature>

    var body: some View {
        Text(store.item.name)
            .navigationDestination(item: $store.scope(state: \.destination?.edit, action: \.destination.edit)) { store in
                Day16NavigationEditScreen(store: store)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("編集") {
                        store.send(.editButtonTapped)
                    }
                }
            }
    }
}

#Preview {
    Day16NavigationDetailScreen(store: Store(initialState: Day16NavigationDetailFeature.State(item: .init(id: UUID(), name: "item1"))) {
        Day16NavigationDetailFeature()
    })
}
