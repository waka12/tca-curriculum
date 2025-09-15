//
//  Day20AppScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import SwiftUI
import ComposableArchitecture

struct Day20AppScreen: View {
    @Bindable var store: StoreOf<Day20AppFeature>

    var body: some View {
        TabView {
            Day20ChannelListScreen(store: store.scope(state: \.channels, action: \.channels))
                .tabItem { Text("Channel") }

            Day20DMScreen(store: store.scope(state: \.dm, action: \.dm))
                .tabItem { Text("dm") }

            Day20SettingsScreen(store: store.scope(state: \.settings, action: \.settings))
                .tabItem { Text("settings") }
        }
        .onChange(of: store.isSendingMentionMessage) { _, newValue in
            store.send(.onChangeIsSendingMentionMessageValue(newValue))
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

#Preview {
    Day20AppScreen(store: Store(initialState: Day20AppFeature.State()) {
        Day20AppFeature()
    })
}
