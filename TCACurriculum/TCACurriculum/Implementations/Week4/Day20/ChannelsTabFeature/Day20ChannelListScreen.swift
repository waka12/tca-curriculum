//
//  Day20ChannelListScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import SwiftUI
import ComposableArchitecture

struct Day20ChannelListScreen: View {
    @Bindable var store: StoreOf<Day20ChannelListFeature>
    var body: some View {
        NavigationStack {
            List(store.items) { item in
                Button(item.name) {
                    store.send(.itemRowTapped(item))
                }
            }
            .navigationDestination(item: $store.scope(state: \.destination?.message, action: \.destination.message)) { store in
                Day20MessageListScreen(store: store)
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
    Day20ChannelListScreen(store: Store(initialState: Day20ChannelListFeature.State(items: [
        .init(id: UUID(), name: "#general", messages: [
            .init(id: UUID(), message: "こんにちは"),
            .init(id: UUID(), message: "hello")
        ]),
        .init(id: UUID(), name: "#random", messages: [
            .init(id: UUID(), message: "マッスル"),
            .init(id: UUID(), message: "いえーい"),
        ])
    ])) {
        Day20ChannelListFeature()
    })
}
