//
//  Day20SettingsScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/13.
//

import SwiftUI
import ComposableArchitecture

struct Day20SettingsScreen: View {
    @Bindable var store: StoreOf<Day20SettingsFeature>
    var body: some View {
        VStack(alignment: .leading) {
            Text("name: Kento Miyabi")
//            Toggle("Notification", isOn: $store.notificationToggle)
            Button("送信") {
                store.send(.sendingButtonTapped)
            }
            .padding(.top, 32)
        }
        .padding()
    }
}

#Preview {
    Day20SettingsScreen(store: Store(initialState: Day20SettingsFeature.State()) {
        Day20SettingsFeature()
    })
}
