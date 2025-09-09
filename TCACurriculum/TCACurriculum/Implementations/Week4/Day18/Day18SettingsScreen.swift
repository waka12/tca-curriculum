//
//  Day18SettingsScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/10.
//

import SwiftUI
import ComposableArchitecture

struct Day18SettingsScreen: View {
    @Bindable var store: StoreOf<Day18SettingsFeature>

    var body: some View {
        Text("設定画面")
    }
}

#Preview {
    Day18SettingsScreen(store: Store(initialState: Day18SettingsFeature.State()){
        Day18SettingsFeature()
    })
}
