//
//  Day12SettingScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/02.
//

import SwiftUI
import ComposableArchitecture

struct Day12SettingScreen: View {
    @Bindable var store: StoreOf<Day12SettingFeature>
    var body: some View {
        VStack {
            Picker("theme", selection: $store.theme) {
                ForEach(Theme.allCases, id: \.self) { theme in
                    Text(theme.rawValue).tag(theme)
                }
            }

            Picker("Push通知", selection: $store.notificationEnabled) {
                ForEach([true, false], id: \.self) { notificationEnabled in
                    Text(notificationEnabled ? "有効" : "無効").tag(notificationEnabled)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    Day12SettingScreen(store: Store(initialState: Day12SettingFeature.State()) {
        Day12SettingFeature()
    } withDependencies: {
        $0.userDefaultsClient = .previewValue
    }
    )
}
