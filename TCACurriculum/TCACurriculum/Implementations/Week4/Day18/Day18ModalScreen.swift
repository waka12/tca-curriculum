//
//  Day18ModalScreen.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/09/10.
//

import SwiftUI
import ComposableArchitecture

struct Day18ModalScreen: View {
    @Bindable var store: StoreOf<Day18ModalFeature>
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Button("新規作成") {
                store.send(.addButtonTapped)
            }
            Button("設定") {
                store.send(.settingsButtonTapped)
            }
            Button("削除") {
                store.send(.deleteButtonTapped)
            }
            Button("保存") {
                store.send(.saveButtonTapped)
            }
        }
        .fullScreenCover(item: $store.scope(state: \.destination?.settings, action: \.destination.settings)) { settingsStore in
            Day18SettingsScreen(store: settingsStore)
        }
        .sheet(item: $store.scope(state: \.destination?.add, action: \.destination.add)) { addStore in
            Day18AddScreen(store: addStore)
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .confirmationDialog($store.scope(state: \.destination?.confirmDialog, action: \.destination.confirmDialog))
    }
}

#Preview {
    Day18ModalScreen(store: Store(initialState: Day18ModalFeature.State()){
        Day18ModalFeature()
    })
}
