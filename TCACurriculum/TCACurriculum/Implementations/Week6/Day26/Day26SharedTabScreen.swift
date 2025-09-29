//
//  Day26SharedTabScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/29.
//

import SwiftUI
import ComposableArchitecture

struct Day26SharedTabScreen: View {
    @Bindable var store: StoreOf<Day26SharedTabFeature>

    var body: some View {
        TabView {
            Day26SharedHomeScreen(store: store.scope(state: \.home, action: \.home))
                .tabItem { Text("home") }

            Day26SharedSettingsScreen(store: store.scope(state: \.settings, action: \.settings))
                .tabItem { Text("settings") }
        }
    }
}

#Preview {
    Day26SharedTabScreen(store: Store(initialState: Day26SharedTabFeature.State()) {
        Day26SharedTabFeature()
    })
}
