//
//  Day26SharedSettingsScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/29.
//

import SwiftUI
import ComposableArchitecture

struct Day26SharedSettingsScreen: View {
    @Bindable var store: StoreOf<Day26SharedSettingsFeature>
    var body: some View {
        VStack(spacing: 16) {
            TextField("ユーザー名", text: $store.editingUserName)
            TextField("未読数", value: $store.editingUnreadCount, format: .number)
            Toggle("ライトモード", isOn: $store.isLightMode)
        }
        .padding()
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    Day26SharedSettingsScreen(store: Store(initialState: Day26SharedSettingsFeature.State()) {
        Day26SharedSettingsFeature()
    })
}
